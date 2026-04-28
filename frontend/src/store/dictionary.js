import { defineStore } from 'pinia'
import { computed, ref, watch } from 'vue'
import { metaApi } from '@/api'
import { locale } from '@/i18n'

export const useDictionaryStore = defineStore('dictionary', () => {
  const loadedLocale = ref('')
  const dictionaries = ref({})
  const loading = ref(false)

  async function load(force = false) {
    if (!force && loadedLocale.value === locale.value && Object.keys(dictionaries.value).length) return dictionaries.value
    loading.value = true
    try {
      const res = await metaApi.dictionaries(locale.value)
      dictionaries.value = res.dictionaries || {}
      loadedLocale.value = res.locale || locale.value
      return dictionaries.value
    } finally {
      loading.value = false
    }
  }

  function label(type, code, fallback = '') {
    if (code == null || code === '') return fallback
    return dictionaries.value?.[type]?.[String(code)] || fallback || String(code)
  }

  function options(type) {
    return Object.entries(dictionaries.value?.[type] || {}).map(([value, label]) => ({ value, label }))
  }

  const ready = computed(() => Object.keys(dictionaries.value).length > 0)

  watch(locale, () => { load(true).catch(() => {}) })

  return { dictionaries, loadedLocale, loading, ready, load, label, options }
})
