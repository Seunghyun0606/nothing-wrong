import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { DashboardPage } from '../../pages/DashboardPage/DashboardPage'
import { LoginPage } from '../../pages/LoginPage/LoginPage'
import { StartPage } from '../../pages/StartPage/StartPage'
import { TicketDetailPage } from '../../pages/TicketDetailPage/TicketDetailPage'
import { ProductRouter } from '../../components/fake-browser/ProductRouter'
import { TestWorkspacePage } from '../../pages/TestWorkspacePage/TestWorkspacePage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/start" element={<StartPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/tickets/:ticketId" element={<TicketDetailPage />} />
        <Route path="/test/:ticketId" element={<TestWorkspacePage />} />
        <Route path="/shoply/product/everyday-pack" element={<ProductRouter path="/shoply/product/everyday-pack" />} />
        <Route path="/shoply/cart" element={<ProductRouter path="/shoply/cart" />} />
        <Route path="/shoply/checkout" element={<ProductRouter path="/shoply/checkout" />} />
        <Route path="*" element={<Navigate to="/start" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
