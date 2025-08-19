import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Next.js Static SPA',
  description: 'A static Next.js application for AWS deployment',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen">
        <nav className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between h-16">
              <div className="flex items-center space-x-8">
                <a href="/" className="text-xl font-bold text-gray-900">
                  My App
                </a>
                <div className="flex space-x-4">
                  <a href="/" className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md">
                    Home
                  </a>
                  <a href="/items/" className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md">
                    Items
                  </a>
                  <a href="/form/" className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md">
                    Add Item
                  </a>
                </div>
              </div>
            </div>
          </div>
        </nav>
        <main>{children}</main>
      </body>
    </html>
  )
}
