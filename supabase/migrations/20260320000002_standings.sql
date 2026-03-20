-- =============================================================
-- Competitiestanden: Match Results
-- =============================================================

CREATE TABLE IF NOT EXISTS public.match_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  home_score INT NOT NULL,
  away_score INT NOT NULL,
  opponent_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT match_results_event_id_key UNIQUE (event_id)
);

CREATE INDEX IF NOT EXISTS idx_match_results_event_id ON public.match_results(event_id);

-- RLS
ALTER TABLE public.match_results ENABLE ROW LEVEL SECURITY;

-- Teamleden kunnen uitslagen lezen
DROP POLICY IF EXISTS "Teamleden kunnen uitslagen lezen" ON public.match_results;
CREATE POLICY "Teamleden kunnen uitslagen lezen" ON public.match_results
  FOR SELECT USING (
    event_id IN (
      SELECT e.id FROM public.events e
      JOIN public.teams t ON t.id = e.team_id
      WHERE t.member_uids @> ARRAY[auth.uid()]
    )
  );

-- Team owner en bestuur kunnen uitslagen beheren
DROP POLICY IF EXISTS "Beheerders beheren uitslagen" ON public.match_results;
CREATE POLICY "Beheerders beheren uitslagen" ON public.match_results
  FOR ALL USING (
    event_id IN (
      SELECT e.id FROM public.events e
      JOIN public.teams t ON t.id = e.team_id
      WHERE t.owner_uid = auth.uid()
         OR t.club_id IN (
           SELECT club_id FROM public.club_members
           WHERE user_uid = auth.uid() AND role IN ('bestuur', 'teamcaptain')
         )
    )
  );

-- Realtime
DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.match_results;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
