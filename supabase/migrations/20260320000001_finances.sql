-- =============================================================
-- Financiën & Contributie tables
-- =============================================================

-- Contributions (door bestuur aangemaakt per team/seizoen)
CREATE TABLE IF NOT EXISTS public.contributions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id     UUID NOT NULL REFERENCES public.teams(id) ON DELETE CASCADE,
  season_year INT  NOT NULL,
  amount_cents INT NOT NULL CHECK (amount_cents > 0),
  description TEXT NOT NULL DEFAULT '',
  due_date    DATE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Payments (één per lid per contributie)
CREATE TABLE IF NOT EXISTS public.payments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contribution_id UUID NOT NULL REFERENCES public.contributions(id) ON DELETE CASCADE,
  user_uid        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount_cents    INT  NOT NULL CHECK (amount_cents > 0),
  status          TEXT NOT NULL DEFAULT 'open'
                    CHECK (status IN ('open', 'paid', 'overdue')),
  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_contributions_team    ON public.contributions(team_id);
CREATE INDEX IF NOT EXISTS idx_contributions_season  ON public.contributions(team_id, season_year);
CREATE INDEX IF NOT EXISTS idx_payments_contribution ON public.payments(contribution_id);
CREATE INDEX IF NOT EXISTS idx_payments_user         ON public.payments(user_uid);
CREATE INDEX IF NOT EXISTS idx_payments_status       ON public.payments(status);

-- RLS
ALTER TABLE public.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Contributions: teamleden mogen lezen
DROP POLICY IF EXISTS "Teamleden kunnen contributies lezen" ON public.contributions;
CREATE POLICY "Teamleden kunnen contributies lezen" ON public.contributions
  FOR SELECT USING (
    team_id IN (SELECT id FROM public.teams WHERE member_uids @> ARRAY[auth.uid()])
  );

-- Contributions: bestuur mag aanmaken/wijzigen/verwijderen
DROP POLICY IF EXISTS "Bestuur beheert contributies" ON public.contributions;
CREATE POLICY "Bestuur beheert contributies" ON public.contributions
  FOR ALL USING (
    team_id IN (
      SELECT t.id FROM public.teams t
      JOIN public.club_members cm ON cm.club_id = t.club_id
      WHERE cm.user_uid = auth.uid() AND cm.role = 'bestuur'
    )
    OR team_id IN (SELECT id FROM public.teams WHERE owner_uid = auth.uid())
  );

-- Payments: spelers zien eigen payments
DROP POLICY IF EXISTS "Spelers zien eigen payments" ON public.payments;
CREATE POLICY "Spelers zien eigen payments" ON public.payments
  FOR SELECT USING (user_uid = auth.uid());

-- Payments: bestuur mag alle payments zien en beheren
DROP POLICY IF EXISTS "Bestuur beheert payments" ON public.payments;
CREATE POLICY "Bestuur beheert payments" ON public.payments
  FOR ALL USING (
    contribution_id IN (
      SELECT c.id FROM public.contributions c
      JOIN public.teams t ON t.id = c.team_id
      WHERE t.owner_uid = auth.uid()
         OR t.club_id IN (
           SELECT club_id FROM public.club_members
           WHERE user_uid = auth.uid() AND role = 'bestuur'
         )
    )
  );

-- Realtime
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.contributions;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
