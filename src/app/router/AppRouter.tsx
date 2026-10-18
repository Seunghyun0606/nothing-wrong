import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { DesktopPage } from '../../pages/DesktopPage/DesktopPage'
import { LoginPage } from '../../pages/LoginPage/LoginPage'
import { StartPage } from '../../pages/StartPage/StartPage'
import { ProductRouter } from '../../components/fake-browser/ProductRouter'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/start" element={<StartPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/desktop" element={<DesktopPage />} />
        <Route path="/dashboard" element={<Navigate to="/desktop" replace />} />
        <Route path="/tickets/*" element={<Navigate to="/desktop" replace />} />
        <Route path="/test/*" element={<Navigate to="/desktop" replace />} />
        <Route path="/reports/*" element={<Navigate to="/desktop" replace />} />
        <Route path="/review/*" element={<Navigate to="/desktop" replace />} />
        <Route path="/shoply/*" element={<ProductRouter />} />
        <Route path="*" element={<Navigate to="/start" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
