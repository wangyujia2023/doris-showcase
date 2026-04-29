export function resolveEntityName(entity, nodeNameMap) {
  if (!entity) return ''
  if (typeof entity === 'string') {
    const mapped = nodeNameMap.value[entity]
    if (mapped) return mapped
    if (/^[0-9a-fA-F-]{36}$/.test(entity)) return ''
    if (entity.includes('.')) return entity.split('.').pop() || ''
    return entity
  }
  if (entity.name) return entity.name
  if (entity.displayName) return entity.displayName
  if (entity.fullyQualifiedName) {
    const parts = entity.fullyQualifiedName.split('.')
    return parts[parts.length - 1] || entity.fullyQualifiedName
  }
  if (entity.id) {
    const mapped = nodeNameMap.value[entity.id]
    if (mapped) return mapped
    if (/^[0-9a-fA-F-]{36}$/.test(entity.id)) return ''
    return entity.id
  }
  return ''
}

export function formatLineageEdge(edge, nodeNameMap) {
  if (!edge) return ''
  const from = resolveEntityName(edge.fromEntity, nodeNameMap)
  const to = resolveEntityName(edge.toEntity, nodeNameMap)
  if (from && to) return `${from} -> ${to}`
  if (from) return from
  if (to) return to
  return ''
}

export function formatExpressionSummary(items) {
  if (!items?.length) return '-'
  return items.map((item) => `${item.target_field || '-'} = ${item.expression || '-'}`).join(' ; ')
}

export function createFieldSpanMethod({ fieldDirectionTab, fieldUpstreamRows, fieldDownstreamRows }) {
  return ({ row, rowIndex, columnIndex }) => {
    const data = fieldDirectionTab.value === 'upstream' ? fieldUpstreamRows.value : fieldDownstreamRows.value
    if (columnIndex !== 0 && columnIndex !== 3) return undefined

    const key = columnIndex === 0 ? 'source_table' : 'target_table'
    const currentTable = row[key]
    const prevTable = data[rowIndex - 1]?.[key]
    if (rowIndex > 0 && currentTable === prevTable) {
      return { rowspan: 0, colspan: 0 }
    }

    let rowspan = 1
    for (let index = rowIndex + 1; index < data.length; index += 1) {
      if (data[index]?.[key] !== currentTable) break
      rowspan += 1
    }
    return { rowspan, colspan: 1 }
  }
}
