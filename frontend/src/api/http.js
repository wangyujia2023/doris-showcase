import axios from 'axios'
import { ElMessage } from 'element-plus'

function handleError(err) {
  ElMessage.error(err.response?.data?.detail || err.message || '请求失败')
  return Promise.reject(err)
}

export function createApiClient(timeout = 30000) {
  const client = axios.create({ baseURL: '/api', timeout })
  client.interceptors.response.use((res) => res.data, handleError)
  return client
}

export const http = createApiClient(30000)
export const httpFast = createApiClient(8000)
export const httpLong = createApiClient(1200000)
export const httpBench = createApiClient(120000)
