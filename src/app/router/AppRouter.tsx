import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { FoundationPage } from '../../pages/FoundationPage/FoundationPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/start" element={<FoundationPage />} />
        <Route path="*" element={<Navigate to="/start" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
