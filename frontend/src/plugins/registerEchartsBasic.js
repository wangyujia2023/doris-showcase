import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, FunnelChart, LineChart, PieChart } from 'echarts/charts'
import { GridComponent, LegendComponent, TooltipComponent } from 'echarts/components'

let registered = false

export function registerEchartsBasic() {
  if (registered) return
  use([
    CanvasRenderer,
    BarChart,
    FunnelChart,
    LineChart,
    PieChart,
    GridComponent,
    LegendComponent,
    TooltipComponent,
  ])
  registered = true
}
