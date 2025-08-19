'use client'

import { useState } from 'react'

export default function Home() {
  const [items, setItems] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const fetchItems = async () => {
    setLoading(true)
    setError('')
    try {
      const response = await fetch('/api/items')
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const data = await response.json()
      setItems(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch items')
      console.error('Error fetching items:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-8">
          Welcome to Next.js Static SPA
        </h1>
        <p className="text-lg text-gray-600 mb-12">
          A modern static React application built with Next.js 14 and TailwindCSS
        </p>
        
        <div className="bg-white rounded-lg shadow-md p-8">
          <h2 className="text-2xl font-semibold text-gray-800 mb-6">
            Fetch Items from API
          </h2>
          
          <button
            onClick={fetchItems}
            disabled={loading}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-semibold py-3 px-6 rounded-lg transition duration-200 mb-6"
          >
            {loading ? 'Loading...' : 'Fetch Items'}
          </button>

          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
              Error: {error}
            </div>
          )}

          {items.length > 0 && (
            <div className="mt-6">
              <h3 className="text-lg font-medium text-gray-800 mb-4">Items Retrieved:</h3>
              <div className="bg-gray-50 rounded-lg p-4">
                <pre className="text-sm text-gray-700 overflow-auto">
                  {JSON.stringify(items, null, 2)}
                </pre>
              </div>
            </div>
          )}
        </div>

        <div className="mt-12 grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">View Items</h3>
            <p className="text-gray-600 mb-4">Browse all items with a styled list view</p>
            <a
              href="/items/"
              className="inline-block bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded transition duration-200"
            >
              Go to Items
            </a>
          </div>
          
          <div className="bg-white rounded-lg shadow-md p-6">
            <h3 className="text-xl font-semibold text-gray-800 mb-3">Add New Item</h3>
            <p className="text-gray-600 mb-4">Create a new item using our form</p>
            <a
              href="/form/"
              className="inline-block bg-purple-600 hover:bg-purple-700 text-white font-medium py-2 px-4 rounded transition duration-200"
            >
              Add Item
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}