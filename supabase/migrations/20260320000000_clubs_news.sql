-- =============================================
-- ClubHub: Clubs, Club Members & News Posts
-- =============================================

-- 1. Clubs table
CREATE TABLE IF NOT EXISTS clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  logo_url TEXT,
  invite_code TEXT UNIQUE DEFAULT substr(md5(random()::text), 1, 8),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Club members table (rollen per club)
CREATE TABLE IF NOT EXISTS club_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
  user_uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'speler' CHECK (role IN ('bestuur', 'teamcaptain', 'speler')),
  display_name TEXT,
  email TEXT,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(club_id, user_uid)
);

-- 3. Add club_id to existing teams table
ALTER TABLE teams ADD COLUMN IF NOT EXISTS club_id UUID REFERENCES clubs(id) ON DELETE SET NULL;

-- 4. News posts table
CREATE TABLE IF NOT EXISTS news_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  club_id UUID REFERENCES clubs(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  author_uid UUID NOT NULL REFERENCES auth.users(id),
  author_name TEXT,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (club_id IS NOT NULL OR team_id IS NOT NULL)
);

-- 5. Indexes
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);
CREATE INDEX IF NOT EXISTS idx_club_members_user_uid ON club_members(user_uid);
CREATE INDEX IF NOT EXISTS idx_teams_club_id ON teams(club_id);
CREATE INDEX IF NOT EXISTS idx_news_posts_club_id ON news_posts(club_id);
CREATE INDEX IF NOT EXISTS idx_news_posts_team_id ON news_posts(team_id);
CREATE INDEX IF NOT EXISTS idx_news_posts_created_at ON news_posts(created_at DESC);

-- 6. RLS Policies
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE news_posts ENABLE ROW LEVEL SECURITY;

-- Clubs policies (idempotent)
DROP POLICY IF EXISTS "Members can view their clubs" ON clubs;
CREATE POLICY "Members can view their clubs" ON clubs
  FOR SELECT USING (
    id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid())
  );

DROP POLICY IF EXISTS "Bestuur can update clubs" ON clubs;
CREATE POLICY "Bestuur can update clubs" ON clubs
  FOR UPDATE USING (
    id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid() AND role = 'bestuur')
  );

DROP POLICY IF EXISTS "Authenticated users can create clubs" ON clubs;
CREATE POLICY "Authenticated users can create clubs" ON clubs
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Bestuur can delete clubs" ON clubs;
CREATE POLICY "Bestuur can delete clubs" ON clubs
  FOR DELETE USING (
    id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid() AND role = 'bestuur')
  );

DROP POLICY IF EXISTS "Anyone can find club by invite code" ON clubs;
CREATE POLICY "Anyone can find club by invite code" ON clubs
  FOR SELECT USING (invite_code IS NOT NULL);

-- Club members policies
DROP POLICY IF EXISTS "Members can view club members" ON club_members;
CREATE POLICY "Members can view club members" ON club_members
  FOR SELECT USING (
    club_id IN (SELECT club_id FROM club_members AS cm WHERE cm.user_uid = auth.uid())
  );

DROP POLICY IF EXISTS "Bestuur can manage members" ON club_members;
CREATE POLICY "Bestuur can manage members" ON club_members
  FOR ALL USING (
    club_id IN (SELECT club_id FROM club_members AS cm WHERE cm.user_uid = auth.uid() AND cm.role = 'bestuur')
  );

DROP POLICY IF EXISTS "Users can join clubs" ON club_members;
CREATE POLICY "Users can join clubs" ON club_members
  FOR INSERT WITH CHECK (user_uid = auth.uid());

-- News posts policies
DROP POLICY IF EXISTS "Members can view news" ON news_posts;
CREATE POLICY "Members can view news" ON news_posts
  FOR SELECT USING (
    club_id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid())
    OR team_id IN (SELECT id FROM teams WHERE member_uids @> ARRAY[auth.uid()])
  );

DROP POLICY IF EXISTS "Bestuur and captains can create news" ON news_posts;
CREATE POLICY "Bestuur and captains can create news" ON news_posts
  FOR INSERT WITH CHECK (
    author_uid = auth.uid()
    AND (
      club_id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid() AND role IN ('bestuur', 'teamcaptain'))
      OR team_id IN (SELECT id FROM teams WHERE owner_uid = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Author or bestuur can delete news" ON news_posts;
CREATE POLICY "Author or bestuur can delete news" ON news_posts
  FOR DELETE USING (
    author_uid = auth.uid()
    OR club_id IN (SELECT club_id FROM club_members WHERE user_uid = auth.uid() AND role = 'bestuur')
  );

-- 7. Enable realtime for new tables (idempotent — ignore if already added)
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE clubs;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE club_members;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE news_posts;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
