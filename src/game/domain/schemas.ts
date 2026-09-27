import { z } from 'zod'

const IdSchema = z.string().trim().min(1)
const TimestampSchema = z.number().int().nonnegative()
const UnknownRecordSchema = z.record(z.string(), z.unknown())

export const TicketStatusSchema = z.enum([
  'NEW',
  'ACCEPTED',
  'TESTING',
  'REPORTED',
  'REVIEWED',
  'RESOLVED',
  'NO_ISSUE',
])

export const PrioritySchema = z.enum(['LOW', 'NORMAL', 'HIGH', 'CRITICAL'])
export const BugSeveritySchema = z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])
export const BugTypeSchema = z.enum([
  'VISUAL',
  'CONTENT',
  'DATA',
  'BEHAVIOR',
  'STATE',
  'CONDITIONAL',
  'CROSS_SCREEN',
])
export const QAAccountSchema = z.enum(['GUEST', 'BASIC', 'GOLD'])
export const ViewportSchema = z.enum(['DESKTOP', 'TABLET', 'MOBILE'])
export const CareerSchema = z.enum(['JUNIOR_QA', 'QA_ENGINEER'])

export const TestContextSchema = z.object({
  account: QAAccountSchema,
  viewport: ViewportSchema,
  locale: z.string().trim().min(1),
  currentPath: z.string().trim().min(1),
})

export const RequirementSchema = z.object({
  id: IdSchema,
  description: z.string().trim().min(1),
  reference: z.string().trim().min(1).optional(),
})

export const AttachmentSchema = z.object({
  id: IdSchema,
  name: z.string().trim().min(1),
  reference: z.string().trim().min(1).optional(),
})

export const HintSchema = z.object({
  id: IdSchema,
  text: z.string().trim().min(1),
})

export const TicketSchema = z.object({
  id: IdSchema,
  projectId: IdSchema,
  title: z.string().trim().min(1),
  sender: z.object({
    id: IdSchema,
    name: z.string().trim().min(1),
    role: z.string().trim().min(1),
  }),
  priority: PrioritySchema,
  request: z.string().trim().min(1),
  scope: z.array(z.string().trim().min(1)).min(1),
  requirements: z.array(RequirementSchema),
  attachments: z.array(AttachmentSchema).optional(),
  startingContext: TestContextSchema,
  hints: z.array(HintSchema).optional(),
  status: TicketStatusSchema,
})

export const MutationOperatorSchema = z.enum([
  'EQ',
  'NEQ',
  'GT',
  'GTE',
  'LT',
  'LTE',
  'IN',
])

export const MutationConditionSchema = z.object({
  field: z.string().trim().min(1),
  operator: MutationOperatorSchema,
  value: z.unknown(),
})

export const MutationTypeSchema = z.enum([
  'REPLACE_TEXT',
  'HIDE_ELEMENT',
  'WRONG_NUMBER',
  'WRONG_STYLE',
  'WRONG_ACTION',
  'WRONG_STATE',
  'WRONG_CALCULATION',
  'CROSS_SCREEN_MISMATCH',
])

export const MutationSchema = z.object({
  id: IdSchema,
  type: MutationTypeSchema,
  target: z.string().trim().min(1),
  conditions: z.array(MutationConditionSchema).optional(),
  payload: UnknownRecordSchema,
})

export const ExpectedBugSchema = z.object({
  id: IdSchema,
  type: BugTypeSchema,
  title: z.string().trim().min(1),
  target: z.string().trim().min(1),
  severity: BugSeveritySchema,
  reproductionConditions: z.array(MutationConditionSchema),
  expected: z.string().trim().min(1),
  actual: z.string().trim().min(1),
  validEvidenceTargets: z.array(z.string().trim().min(1)).min(1),
})

export const EvidenceSchema = z
  .object({
    id: IdSchema,
    ticketId: IdSchema,
    type: z.literal('SCREENSHOT'),
    path: z.string().trim().min(1).optional(),
    preview: z.string().trim().min(1).optional(),
    capturedAt: TimestampSchema,
    context: TestContextSchema,
    snapshot: UnknownRecordSchema,
  })
  .refine((evidence) => evidence.path !== undefined || evidence.preview !== undefined, {
    message: 'Evidence requires a path or preview',
    path: ['preview'],
  })

export const TicketNoteSchema = z.object({
  ticketId: IdSchema,
  content: z.string(),
})

export const PlayerActionSchema = z.object({
  id: IdSchema,
  ticketId: IdSchema,
  timestamp: TimestampSchema,
  type: z.string().trim().min(1),
  target: z.string().trim().min(1).optional(),
  payload: UnknownRecordSchema.optional(),
})

export const ReportStepSchema = z.object({
  id: IdSchema,
  order: z.number().int().nonnegative(),
  action: z.string().trim().min(1),
  target: z.string().trim().min(1).optional(),
  details: z.string().trim().min(1).optional(),
})

export const BugReportSchema = z.object({
  id: IdSchema,
  ticketId: IdSchema,
  title: z.string().trim().min(1),
  reproductionSteps: z.array(ReportStepSchema).min(1),
  expected: z.string().trim().min(1),
  actual: z.string().trim().min(1),
  severity: BugSeveritySchema,
  evidenceIds: z.array(IdSchema),
  submittedAt: TimestampSchema,
})

export const ReviewResultSchema = z.object({
  valid: z.boolean(),
  matchedBugId: IdSchema.optional(),
  scores: z.object({
    detection: z.number().nonnegative(),
    reproduction: z.number().nonnegative(),
    evidence: z.number().nonnegative(),
    severity: z.number().nonnegative(),
  }),
  totalScore: z.number().nonnegative(),
  xp: z.number().int().nonnegative(),
  reputationDelta: z.number().int(),
  feedback: z.array(z.string().trim().min(1)),
})

export const ScoringConfigSchema = z
  .object({
    detection: z.number().nonnegative(),
    reproduction: z.number().nonnegative(),
    evidence: z.number().nonnegative(),
    severity: z.number().nonnegative(),
  })
  .refine(
    (scoring) =>
      scoring.detection + scoring.reproduction + scoring.evidence + scoring.severity ===
      100,
    { message: 'Scoring weights must total 100' },
  )

export const ProgressionRewardSchema = z.object({
  xp: z.number().int().nonnegative(),
  reputationDelta: z.number().int(),
  unlockedTools: z.array(IdSchema).optional(),
})

export const NarrativeHookSchema = z.object({
  eventId: IdSchema.optional(),
  tags: z.array(z.string().trim().min(1)).optional(),
  clueIds: z.array(IdSchema).optional(),
  entityIds: z.array(IdSchema).optional(),
  persistentChanges: z.array(z.string().trim().min(1)).optional(),
})

export const ScenarioSeedSchema = z.object({
  productState: UnknownRecordSchema,
  context: TestContextSchema.partial().optional(),
})

export const AccountSwitchPolicySchema = z.object({
  resetProductState: z.boolean(),
})

export const ScenarioSchema = z.object({
  id: IdSchema,
  ticket: TicketSchema,
  seed: ScenarioSeedSchema,
  accountSwitchPolicy: AccountSwitchPolicySchema.optional(),
  expectedBugs: z.array(ExpectedBugSchema),
  mutations: z.array(MutationSchema),
  scoring: ScoringConfigSchema,
  progression: ProgressionRewardSchema.optional(),
  narrative: NarrativeHookSchema.optional(),
})

export const PlayerProfileSchema = z.object({
  name: z.string().trim().min(1),
  level: z.number().int().positive(),
  career: CareerSchema,
  xp: z.number().int().nonnegative(),
  reputation: z.number().int(),
})

export const PlayerTicketStateSchema = z.object({
  status: TicketStatusSchema,
  reportIds: z.array(IdSchema),
  acceptedAt: TimestampSchema.optional(),
  reviewedAt: TimestampSchema.optional(),
  resolvedAt: TimestampSchema.optional(),
})

export const GameStateSchema = z.object({
  profile: PlayerProfileSchema,
  tickets: z.record(IdSchema, PlayerTicketStateSchema),
  currentTicketId: IdSchema.optional(),
  unlockedTools: z.array(IdSchema),
  reportHistory: z.array(BugReportSchema),
  reviewHistory: z.array(ReviewResultSchema),
})

export const SAVE_VERSION = 1 as const

export const SaveFileSchema = z.object({
  version: z.literal(SAVE_VERSION),
  state: GameStateSchema,
})

export type TicketStatus = z.infer<typeof TicketStatusSchema>
export type Priority = z.infer<typeof PrioritySchema>
export type BugSeverity = z.infer<typeof BugSeveritySchema>
export type BugType = z.infer<typeof BugTypeSchema>
export type QAAccount = z.infer<typeof QAAccountSchema>
export type Viewport = z.infer<typeof ViewportSchema>
export type Career = z.infer<typeof CareerSchema>
export type TestContext = z.infer<typeof TestContextSchema>
export type Requirement = z.infer<typeof RequirementSchema>
export type Attachment = z.infer<typeof AttachmentSchema>
export type Hint = z.infer<typeof HintSchema>
export type Ticket = z.infer<typeof TicketSchema>
export type MutationOperator = z.infer<typeof MutationOperatorSchema>
export type MutationCondition = z.infer<typeof MutationConditionSchema>
export type MutationType = z.infer<typeof MutationTypeSchema>
export type Mutation = z.infer<typeof MutationSchema>
export type ExpectedBug = z.infer<typeof ExpectedBugSchema>
export type Evidence = z.infer<typeof EvidenceSchema>
export type TicketNote = z.infer<typeof TicketNoteSchema>
export type PlayerAction = z.infer<typeof PlayerActionSchema>
export type ReportStep = z.infer<typeof ReportStepSchema>
export type BugReport = z.infer<typeof BugReportSchema>
export type ReviewResult = z.infer<typeof ReviewResultSchema>
export type ScoringConfig = z.infer<typeof ScoringConfigSchema>
export type ProgressionReward = z.infer<typeof ProgressionRewardSchema>
export type NarrativeHook = z.infer<typeof NarrativeHookSchema>
export type ScenarioSeed = z.infer<typeof ScenarioSeedSchema>
export type AccountSwitchPolicy = z.infer<typeof AccountSwitchPolicySchema>
export type Scenario = z.infer<typeof ScenarioSchema>
export type PlayerProfile = z.infer<typeof PlayerProfileSchema>
export type PlayerTicketState = z.infer<typeof PlayerTicketStateSchema>
export type GameState = z.infer<typeof GameStateSchema>
export type SaveFile = z.infer<typeof SaveFileSchema>
