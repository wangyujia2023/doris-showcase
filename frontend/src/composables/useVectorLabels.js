const LABEL_PALETTE = ['#E6A23C', '#5CB6D6', '#67C23A', '#409EFF', '#8E7CC3', '#E87C8A', '#5ABFAC', '#D97AA8', '#909399', '#7BC96F', '#A78BFA', '#E98A3A', '#64B5F6', '#95C85A', '#F56C6C', '#7B8CEB', '#C084D8']

export function useVectorLabels(labels, dictionary) {
  function labelText(name) {
    const key = labelName(name)
    return dictionary.label('vector_tags', key, key)
  }

  function labelMeta(name) {
    const key = labelName(name)
    return labels.value.find(lb => lb.label_name === key || labelText(lb.label_name) === key) || {}
  }

  function labelColor(name) {
    const meta = labelMeta(name)
    if (isUsefulColor(meta.color)) return meta.color
    const source = labelName(name)
    const idx = [...source].reduce((sum, ch) => sum + ch.charCodeAt(0), 0) % LABEL_PALETTE.length
    return LABEL_PALETTE[idx]
  }

  function labelChipStyle(name) {
    const color = labelColor(name)
    return {
      '--label-color': color,
      '--label-soft-bg': softBg(color, '14'),
      color,
      borderColor: softBorder(color),
      background: `linear-gradient(135deg, ${softBg(color, '12')} 0%, #ffffff 100%)`,
    }
  }

  function labelSelectorStyle(label, selected) {
    const color = isUsefulColor(label.color) ? label.color : labelColor(label.label_name)
    if (!selected) {
      return { '--label-color': color, color, borderColor: softBorder(color), background: '#fff' }
    }
    return {
      '--label-color': color,
      '--label-soft-bg': softBg(color, '16'),
      color,
      borderColor: softBorder(color),
      background: `linear-gradient(135deg, ${softBg(color, '16')} 0%, #ffffff 100%)`,
    }
  }

  return { labelText, labelColor, labelChipStyle, labelSelectorStyle }
}

function isUsefulColor(color) {
  const value = String(color || '').trim().toLowerCase()
  if (!value || ['black', 'null', 'none', 'undefined', '0', '#000', '#000000', '#111', '#111111', '#222', '#222222', '#333', '#333333'].includes(value)) {
    return false
  }
  return /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(value)
    || /^rgba?\(/i.test(value)
    || /^hsla?\(/i.test(value)
}

function labelName(label) {
  if (label && typeof label === 'object') {
    return String(label.label_name || label.name || label.label || '')
  }
  return String(label || '')
}

function softBg(color, alpha) {
  return `${color}${alpha}`
}

function softBorder(color) {
  return `${color}88`
}
