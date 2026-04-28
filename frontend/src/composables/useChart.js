import { onBeforeUnmount } from 'vue'
import * as echarts from 'echarts'

export function useDomChart() {
  const charts = new Map()

  function renderChart(id, option) {
    const el = typeof id === 'string' ? document.getElementById(id) : id?.value || id
    if (!el) return null
    let chart = charts.get(el)
    if (!chart) {
      chart = echarts.init(el)
      charts.set(el, chart)
    }
    chart.setOption(option, true)
    return chart
  }

  function resizeAll() {
    charts.forEach(chart => chart.resize())
  }

  if (typeof window !== 'undefined') window.addEventListener('resize', resizeAll)

  onBeforeUnmount(() => {
    if (typeof window !== 'undefined') window.removeEventListener('resize', resizeAll)
    charts.forEach(chart => chart.dispose())
    charts.clear()
  })

  return { renderChart, resizeAll }
}
