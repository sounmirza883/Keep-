// Due-date reminder dispatcher — invoked by pg_cron on a schedule.
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Tasks due within the next hour that are still open
  const { data: tasks, error } = await supabase
    .from('tasks')
    .select('id, title, user_id')
    .eq('status', 'todo')
    .eq('is_deleted', false)
    .gte('due_date', new Date().toISOString())
    .lte('due_date', new Date(Date.now() + 3600000).toISOString())

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }

  // Push delivery (FCM/APNs) ships in v2 — this endpoint reports counts for now.
  return new Response(JSON.stringify({ notified: tasks?.length ?? 0 }))
})
