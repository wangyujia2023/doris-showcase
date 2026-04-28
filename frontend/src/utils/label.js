import { useDictionaryStore } from '@/store/dictionary'

export function dictLabel(type, code, fallback = '') {
  return useDictionaryStore().label(type, code, fallback)
}

export function dictOptions(type) {
  return useDictionaryStore().options(type)
}
