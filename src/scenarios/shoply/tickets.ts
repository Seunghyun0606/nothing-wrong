import { TicketSchema, type Ticket } from '../../game/domain/schemas'

const tickets = [
  TicketSchema.parse({
    id: 'T01',
    projectId: 'shoply',
    title: 'Checkout confirmation design review',
    sender: {
      id: 'maya-kim',
      name: 'Maya Kim',
      role: 'QA Lead',
    },
    priority: 'HIGH',
    request:
      'Review the purchase path before release. Confirm the product, cart, and checkout experience matches the approved requirements.',
    scope: ['Product detail', 'Cart', 'Checkout'],
    requirements: [
      {
        id: 'REQ-T01-01',
        description: 'Customers can add a product to the cart and continue to checkout.',
      },
      {
        id: 'REQ-T01-02',
        description: 'The final confirmation control is presented as the primary action.',
        reference: 'Checkout interaction specification',
      },
    ],
    attachments: [
      {
        id: 'ATT-T01-01',
        name: 'Checkout interaction specification',
        reference: 'Design system / checkout actions',
      },
    ],
    startingContext: {
      account: 'BASIC',
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/shoply/product/everyday-pack',
    },
    hints: [
      {
        id: 'HINT-T01-01',
        text: 'Follow the complete customer journey before recording a conclusion.',
      },
    ],
    status: 'NEW',
  }),
] satisfies Ticket[]

export const TICKET_CATALOG: readonly Ticket[] = tickets

export function getTicket(ticketId: string): Ticket | undefined {
  return TICKET_CATALOG.find((ticket) => ticket.id === ticketId)
}
