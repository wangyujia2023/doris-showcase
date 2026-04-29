<template>
  <div v-if="vec?.length" class="vec-bar">
    <div v-for="(value, index) in vec" :key="index" class="vec-col">
      <div class="vec-stick" :class="{ hot: normalized(value) > 0.65 }" :style="{ height: `${Math.round(normalized(value) * 40)}px` }" />
      <div class="vec-label">{{ shortLabel(index) }}</div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  vec: { type: Array, default: () => [] },
  dimLabels: { type: Array, default: () => [] },
})

function maxValue() {
  return Math.max(...props.vec, 0.01)
}

function normalized(value) {
  return Number(value || 0) / maxValue()
}

function shortLabel(index) {
  return String(props.dimLabels?.[index] || `d${index}`).slice(0, 3)
}
</script>

<style scoped>
.vec-bar { display: flex; gap: 8px; align-items: flex-end; justify-content: space-between; width: 100%; margin-top: 6px; overflow: hidden; }
.vec-col { flex: 1; display: flex; flex-direction: column; align-items: center; gap: 3px; min-width: 22px; }
.vec-stick { width: 100%; max-width: 34px; min-height: 2px; border-radius: 3px 3px 0 0; background: #c6e2ff; opacity: 0.9; }
.vec-stick.hot { background: #409eff; }
.vec-label { height: 36px; color: #909399; font-size: 9px; line-height: 1.2; text-align: center; writing-mode: vertical-rl; }
</style>
