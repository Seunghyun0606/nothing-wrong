import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { DashboardPage } from '../../pages/DashboardPage/DashboardPage'
import { LoginPage } from '../../pages/LoginPage/LoginPage'
import { StartPage } from '../../pages/StartPage/StartPage'
import { TicketDetailPage } from '../../pages/TicketDetailPage/TicketDetailPage'
import { ProductRouter } from '../../components/fake-browser/ProductRouter'
import { TestWorkspacePage } from '../../pages/TestWorkspacePage/TestWorkspacePage'
import { ReportBuilderPage } from '../../pages/ReportBuilderPage/ReportBuilderPage'
import { ReviewResultPage } from '../../pages/ReviewResultPage/ReviewResultPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/start" element={<StartPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/tickets/:ticketId" element={<TicketDetailPage />} />
        <Route path="/test/:ticketId" element={<TestWorkspacePage />} />
        <Route path="/reports/:ticketId" element={<ReportBuilderPage />} />
        <Route path="/review/:ticketId" element={<ReviewResultPage />} />
        <Route path="/shoply/product/everyday-pack" element={<ProductRouter path="/shoply/product/everyday-pack" />} />
        <Route path="/shoply/cart" element={<ProductRouter path="/shoply/cart" />} />
        <Route path="/shoply/checkout" element={<ProductRouter path="/shoply/checkout" />} />
        <Route path="*" element={<Navigate to="/start" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
