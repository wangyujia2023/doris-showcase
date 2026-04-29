import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const shortText = (value, length = 30) => {
  const text = String(value || '')
  if (!text) return ''
  return text.length > length ? `${text.slice(0, length - 1)}...` : text
}

export function useLineageGraph({ selectedTable, omLineage, upstreamList, downstreamList }) {
  const graphBox = { width: 2200, height: 980 }
  const graphViewport = ref({ scale: 1, x: 0, y: 0 })
  const graphDrag = ref({ active: false, startX: 0, startY: 0, baseX: 0, baseY: 0 })

  const graphNodes = computed(() => {
    const current = omLineage.value?.entity || {}
    const nodeMap = new Map()
    const incoming = new Map()
    const outgoing = new Map()

    const addNode = (node) => {
      if (!node?.id) return
      nodeMap.set(node.id, {
        id: node.id,
        title: node.displayName || node.name || node.fullyQualifiedName?.split('.')?.pop() || node.id,
        sub: shortText(node.fullyQualifiedName || ''),
        kind: 'up',
      })
    }

    addNode(current)
    ;(omLineage.value?.nodes || []).forEach(addNode)

    const addEdge = (from, to) => {
      if (!from || !to) return
      if (!incoming.has(to)) incoming.set(to, new Set())
      if (!outgoing.has(from)) outgoing.set(from, new Set())
      incoming.get(to).add(from)
      outgoing.get(from).add(to)
    }

    ;(upstreamList.value || []).forEach((edge) => addEdge(edge.fromEntity, edge.toEntity))
    ;(downstreamList.value || []).forEach((edge) => addEdge(edge.fromEntity, edge.toEntity))

    const seedId = current.id || selectedTable.value
    const levelOf = new Map([[seedId, 0]])
    const queue = [seedId]

    while (queue.length) {
      const id = queue.shift()
      const level = levelOf.get(id) || 0
      ;(incoming.get(id) || []).forEach((source) => {
        if (!levelOf.has(source)) {
          levelOf.set(source, level - 1)
          queue.push(source)
        }
      })
      ;(outgoing.get(id) || []).forEach((target) => {
        if (!levelOf.has(target)) {
          levelOf.set(target, level + 1)
          queue.push(target)
        }
      })
    }

    const byLevel = new Map()
    for (const [id, info] of nodeMap.entries()) {
      const level = levelOf.get(id)
      if (level === undefined) continue
      if (!byLevel.has(level)) byLevel.set(level, [])
      byLevel.get(level).push({ ...info, id })
    }

    const centerX = graphBox.width / 2
    const centerY = graphBox.height / 2
    const nodes = []

    const levelX = (level) => {
      if (level === 0) return centerX
      const side = level < 0 ? -1 : 1
      const depth = Math.abs(level)
      return centerX + side * (260 + (depth - 1) * 360)
    }

    const levelY = (level) => {
      if (level === 0) return centerY
      const depth = Math.abs(level)
      const band = Math.ceil(depth / 2)
      const offset = band * 170
      const direction = depth % 2 === 1 ? -1 : 1
      return centerY + direction * offset
    }

    ;[...byLevel.keys()].sort((a, b) => a - b).forEach((level) => {
      const items = byLevel.get(level) || []
      const gap = level === 0 ? 0 : Math.min(180, Math.max(120, 360 / Math.max(items.length || 1, 1)))
      const startY = level === 0 ? centerY : levelY(level) - ((items.length - 1) * gap) / 2

      items.forEach((item, index) => {
        const baseWidth = level === 0 ? 300 : 260
        nodes.push({
          key: item.id,
          title: item.title,
          sub: item.sub,
          kind: level === 0 ? 'center' : (level < 0 ? 'up' : 'down'),
          x: levelX(level),
          y: startY + index * gap,
          w: Math.max(baseWidth, Math.min(380, 170 + String(item.title || '').length * 10)),
          h: level === 0 ? 96 : 78,
        })
      })
    })

    return nodes
  })

  const graphLinks = computed(() => {
    const pos = new Map(graphNodes.value.map((node) => [node.key, node]))
    const lines = []

    const addEdgeLine = (from, to, stroke) => {
      const source = pos.get(from)
      const target = pos.get(to)
      if (!source || !target) return
      const forward = target.x >= source.x
      const sx = source.x + (forward ? source.w / 2 : -source.w / 2)
      const sy = source.y
      const ex = target.x - (forward ? target.w / 2 : -target.w / 2)
      const ey = target.y
      const midX = (sx + ex) / 2
      const bend = Math.max(80, Math.min(220, Math.abs(ex - sx) / 2))
      lines.push({
        stroke,
        d: `M ${sx} ${sy} C ${sx + bend} ${sy}, ${midX - bend} ${ey}, ${ex} ${ey}`,
      })
    }

    ;(upstreamList.value || []).forEach((edge) => addEdgeLine(edge.fromEntity, edge.toEntity, 'url(#lineUp)'))
    ;(downstreamList.value || []).forEach((edge) => addEdgeLine(edge.fromEntity, edge.toEntity, 'url(#lineDown)'))
    return lines
  })

  const onGraphWheel = (event) => {
    event.preventDefault()
    const delta = event.deltaY > 0 ? -0.08 : 0.08
    graphViewport.value = {
      ...graphViewport.value,
      scale: Math.min(1.8, Math.max(0.6, graphViewport.value.scale + delta)),
    }
  }

  const onGraphDown = (event) => {
    graphDrag.value = {
      active: true,
      startX: event.clientX,
      startY: event.clientY,
      baseX: graphViewport.value.x,
      baseY: graphViewport.value.y,
    }
  }

  const onGraphMove = (event) => {
    if (!graphDrag.value.active) return
    graphViewport.value = {
      ...graphViewport.value,
      x: graphDrag.value.baseX + (event.clientX - graphDrag.value.startX),
      y: graphDrag.value.baseY + (event.clientY - graphDrag.value.startY),
    }
  }

  const onGraphUp = () => {
    graphDrag.value.active = false
  }

  const resetGraph = () => {
    graphViewport.value = { scale: 1, x: 0, y: 0 }
  }

  onMounted(() => {
    window.addEventListener('mousemove', onGraphMove)
    window.addEventListener('mouseup', onGraphUp)
  })

  onBeforeUnmount(() => {
    window.removeEventListener('mousemove', onGraphMove)
    window.removeEventListener('mouseup', onGraphUp)
  })

  return {
    graphBox,
    graphViewport,
    graphNodes,
    graphLinks,
    onGraphWheel,
    onGraphDown,
    resetGraph,
  }
}
