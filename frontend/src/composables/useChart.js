import { onBeforeUnmount } from 'vue'
import { use, init } from 'echarts/core'
import { BarChart, LineChart, PieChart, RadarChart } from 'echarts/charts'
import {
  GridComponent, TooltipComponent, LegendComponent,
  MarkLineComponent, DataZoomComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

use([
  BarChart, LineChart, PieChart, RadarChart,
  GridComponent, TooltipComponent, LegendComponent,
  MarkLineComponent, DataZoomComponent,
  CanvasRenderer,
])

export function useDomChart() {
  const charts = new Map()

  function renderChart(id, option) {
    const el = typeof id === 'string' ? document.getElementById(id) : id?.value || id
    if (!el) return null
    let chart = charts.get(el)
    if (!chart) {
      chart = init(el)
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
