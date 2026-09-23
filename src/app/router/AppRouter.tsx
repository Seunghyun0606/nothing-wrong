import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'

import { DashboardPage } from '../../pages/DashboardPage/DashboardPage'
import { LoginPage } from '../../pages/LoginPage/LoginPage'
import { StartPage } from '../../pages/StartPage/StartPage'
import { TicketDetailPage } from '../../pages/TicketDetailPage/TicketDetailPage'
import { CartPage } from '../../products/shoply/pages/CartPage'
import { CheckoutPage } from '../../products/shoply/pages/CheckoutPage'
import { ProductPage } from '../../products/shoply/pages/ProductPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/start" element={<StartPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/tickets/:ticketId" element={<TicketDetailPage />} />
        <Route path="/shoply/product/:productId" element={<ProductPage />} />
        <Route path="/shoply/cart" element={<CartPage />} />
        <Route path="/shoply/checkout" element={<CheckoutPage />} />
        <Route path="*" element={<Navigate to="/start" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
