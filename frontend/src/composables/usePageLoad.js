import { onMounted, ref } from 'vue'

export function usePageLoad(loader, { immediate = true } = {}) {
  const loading = ref(false)
  const error = ref('')

  async function run(...args) {
    loading.value = true
    error.value = ''
    try {
      return await loader(...args)
    } catch (err) {
      error.value = err?.response?.data?.detail || err?.message || String(err)
      throw err
    } finally {
      loading.value = false
    }
  }

  if (immediate) onMounted(() => run().catch(() => {}))

  return { loading, error, run }
}
