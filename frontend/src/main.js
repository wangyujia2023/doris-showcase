import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './styles/layout.css'
import { useDictionaryStore } from './store/dictionary'
import './styles/app.css'
import './styles/setup.css'

const app = createApp(App)

const pinia = createPinia()
app.use(pinia)
app.use(router)
useDictionaryStore(pinia).load().catch(() => {})
app.mount('#app')
