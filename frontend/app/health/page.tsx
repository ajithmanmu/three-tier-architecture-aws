export default function HealthPage() {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <h1 className="text-6xl font-bold text-green-600 mb-4">OK</h1>
          <p className="text-gray-600">Health check endpoint</p>
          <div className="mt-8 text-sm text-gray-500">
            <p>Status: Healthy</p>
            <p>Timestamp: {new Date().toISOString()}</p>
          </div>
        </div>
      </div>
    )
  }