import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, fileURLToPath(new URL('..', import.meta.url)), '')
  const frontendPort = Number(env.FRONTEND_PORT || 5173)
  const backendPort = Number(env.BACKEND_PORT || 8000)
  const backendProxyHost = env.BACKEND_PROXY_HOST || env.BACKEND_HOST || '127.0.0.1'

  return {
    envDir: '..',
    plugins: [
      vue(),
      AutoImport({ resolvers: [ElementPlusResolver({ importStyle: 'css' })] }),
      Components({ resolvers: [ElementPlusResolver({ importStyle: 'css' })] }),
    ],
    resolve: {
      alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) }
    },
    build: {
      rollupOptions: {
        output: {
          manualChunks(id) {
            if (!id.includes('node_modules')) return
            if (
              id.includes('/node_modules/vue/') ||
              id.includes('/node_modules/@vue/') ||
              id.includes('/node_modules/pinia/') ||
              id.includes('/node_modules/vue-router/')
            ) return 'vendor-vue'

            if (id.includes('/node_modules/@element-plus/icons-vue/')) return 'vendor-ep-icons'
            if (id.includes('/node_modules/element-plus/')) return

            if (id.includes('/node_modules/echarts/')) return 'vendor-echarts'
            if (id.includes('/node_modules/zrender/')) return 'vendor-echarts'
            if (id.includes('/node_modules/vue-echarts/')) return 'vendor-echarts'

            return 'vendor-misc'
          }
        }
      }
    },
    server: {
      host: env.FRONTEND_HOST || '0.0.0.0',
      port: frontendPort,
      proxy: {
        '/api': { target: `http://${backendProxyHost}:${backendPort}`, changeOrigin: true }
      }
    }
  }
})
