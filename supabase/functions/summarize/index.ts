import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// Gemini API의 엔드포인트와 키를 환경변수에서 가져옵니다.
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${Deno.env.get('GEMINI_API_KEY')}`;

serve(async (req) => {
  // CORS preflight 요청 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    );

    // 1. 요청 본문에서 recordId 가져오기
    const { recordId, meetingContext } = await req.json();
    if (!recordId) {
      throw new Error('recordId가 제공되지 않았습니다.');
    }

    // 2. DB에서 해당 레코드의 원본 스크립트 가져오기
    const { data: record, error: fetchError } = await supabaseClient
      .from('transcripts')
      .select('transcript')
      .eq('id', recordId)
      .single();

    if (fetchError) throw fetchError;

    // 3. Gemini API에 보낼 프롬프트 구성
    const now = new Date();
    // KST is UTC+9
    const kstOffset = 9 * 60 * 60 * 1000;
    const kstDate = new Date(now.getTime() + kstOffset);
    const kstTimeString = kstDate.toISOString().slice(0, 19).replace('T', ' ').substring(0, 16);

    const contextLine = meetingContext ? `${meetingContext}` : '스크립트 전체 내용 요약';
    const prompt = `
당신은 회의록을 작성하는 유용한 어시스턴트입니다.
제공된 스크립트를 바탕으로 한국어로 회의 요약을 작성해주세요.
아래 형식을 정확히 따라주세요.

**[회의록]**

**1. 개요**
- **회의주제:** ${contextLine}
- **회의시간:** ${kstTimeString}

**2. 요약**
- **주요 안건:**
  - (논의된 핵심 안건을 번호나 글머리 기호로 요약)

**3. 주요 내용**
- (각 주요 안건에 대한 상세 논의 내용을 서술)

---
**[원본 스크립트]**
${record.transcript}
    `;

    // 4. Gemini API 호출
    const geminiRes = await fetch(GEMINI_API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
      }),
    });

    if (!geminiRes.ok) {
      const errorBody = await geminiRes.text();
      throw new Error(`Gemini API 호출 실패: ${errorBody}`);
    }

    const geminiData = await geminiRes.json();
    const summary = geminiData.candidates[0].content.parts[0].text;

    // 5. DB에 요약 결과와 함께 상태 업데이트
    const { error: updateError } = await supabaseClient
      .from('transcripts')
      .update({ summary: summary, status: 'completed' })
      .eq('id', recordId);

    if (updateError) throw updateError;

    // 6. 성공 응답 반환
    return new Response(JSON.stringify({ message: '요약 성공' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    // 7. 에러 처리
    console.error(error);
    // 에러 발생 시 DB 상태를 'failed'로 업데이트
    const { recordId } = await req.json();
    if (recordId) {
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
        );
        await supabaseClient
            .from('transcripts')
            .update({ status: 'failed', summary: `요약 실패: ${error.message}` })
            .eq('id', recordId);
    }

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});