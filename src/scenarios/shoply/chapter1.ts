import { StoryChapterSchema } from '../../game/domain/schemas'

export const CHAPTER_1 = StoryChapterSchema.parse({
  id: 'CH1',
  title: 'Chapter 1 · Release Candidate 3',
  synopsis:
    'Shoply ships its Autumn Release on Friday. Release Manager Daniel Reyes insists Release Candidate 3 is clean: "Nothing wrong with this build." Test it, and work out why RC3 behaves like a different product.',
  finaleDeductionId: 'DED-T04',
  epilogue: [
    {
      from: 'Daniel Reyes',
      role: 'Shoply Release Manager',
      text: "...That was me. I widened the merge rule so new promo branches would ship on their own. I didn't know the archived branches still matched.",
    },
    {
      from: 'Maya Kim',
      role: 'QA Lead',
      text: "That's a root cause, not four separate bugs. RC3 is pulled, the rule is fixed, and Friday's release is safe. Good work.",
    },
    {
      from: 'Maya Kim',
      role: 'QA Lead',
      text: 'One thing still bothers me. The archive was supposed to be read-only. Someone gave release-bot access to it. That is a question for next week.',
    },
  ],
})

export const STORY_CHAPTERS = [CHAPTER_1] as const
