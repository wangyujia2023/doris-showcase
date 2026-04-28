import { computed, ref } from 'vue'
import { messages } from './messages'

const STORAGE_KEY = 'doris-showcase-locale'
const DEFAULT_LOCALE = 'zh'

const LOCALE_ALIASES = {
  zh: 'zh',
  'zh-CN': 'zh',
  cn: 'zh',
  en: 'en',
  'en-US': 'en',
  'en-GB': 'en',
}

const normalize = (value) => {
  const key = String(value || '').trim()
  return LOCALE_ALIASES[key] || (messages[key] ? key : DEFAULT_LOCALE)
}

function getByPath(source, path) {
  return String(path || '').split('.').reduce((cur, part) => cur?.[part], source)
}

function interpolate(value, params) {
  if (typeof value !== 'string' || params == null) return value
  if (Array.isArray(params)) {
    return params.reduce((text, item, index) => text.replaceAll(`{${index}}`, item), value)
  }
  return Object.entries(params).reduce((text, [key, item]) => text.replaceAll(`{${key}}`, item), value)
}

export const locale = ref(normalize(localStorage.getItem(STORAGE_KEY)))

export function setLocale(lang) {
  locale.value = normalize(lang)
  localStorage.setItem(STORAGE_KEY, locale.value)
}

export const currentMessages = computed(() => messages[locale.value] || messages[DEFAULT_LOCALE])

export function t(path, params) {
  const currentValue = getByPath(messages[locale.value], path)
  const fallbackValue = getByPath(messages[DEFAULT_LOCALE], path)
  return interpolate(currentValue ?? fallbackValue ?? path, params)
}

export const locales = [
  { value: 'zh', code: 'zh-CN', label: () => t('locale.zh') },
  { value: 'en', code: 'en-US', label: () => t('locale.en') },
]

export { messages }
