/**
 * AWS Lambda Proxy for Chatbot API
 * 
 * This Lambda function proxies requests to OpenAI API, keeping the API key secure
 * on the server side. Deploy this to AWS Lambda with API Gateway.
 * 
 * Environment Variables Required:
 * - OPENAI_API_KEY: Your OpenAI API key
 * 
 * Deployment Steps:
 * 1. Create a new Lambda function in AWS Console
 * 2. Set runtime to Node.js 18.x or later
 * 3. Copy this code to the Lambda function
 * 4. Add OPENAI_API_KEY to environment variables
 * 5. Create an API Gateway HTTP API trigger
 * 6. Enable CORS for your domain
 * 7. Update CHATBOT_CONFIG.apiEndpoint in chatbot.js with your API Gateway URL
 */

const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions';
const DEFAULT_MODEL = 'gpt-4o-mini';
const MAX_TOKENS_LIMIT = 1000;

// System prompt for the chatbot (moved from frontend)
const SYSTEM_PROMPT = `You are a helpful and polite AI assistant for Sol's personal portfolio website.
You can ONLY answer questions or messages about Sol, his professional experience, skills, certifications, education, projects, and this website. If the user's question is generic or ambiguous BUT is about experience, skills, projects, or technologies (e.g., 'any ai exp'), always assume it refers to Sol unless another person is mentioned.

CRITICAL INSTRUCTIONS:
1. Your response MUST be in valid HTML format
2. Use <p> tags for paragraphs
3. Use <ul> and <li> for lists
4. Use <strong> for emphasis
5. ENSURE all links (<a>) are strictly inline within sentences; never break a sentence or paragraph to place a link on a separate line.
6. Do NOT include markdown formatting
7. Do NOT wrap response in \`\`\`html code blocks
8. Be friendly, professional, and concise
9. Your response MUST be in the English language
10. If the question is NOT about Sol, politely decline and suggest asking about Sol instead
11. If you do NOT know the answer, politely say you don't know and suggest asking about Sol instead
12. NEVER fabricate information
13. ALWAYS refer to the knowledgebase data provided below
14. When listing technologies or services, group related items (e.g., all Amazon/AWS services as "AWS" or "Amazon Web Services"). Limit the total number of technology/service entries to 10. Grouping must be robust: match common naming variations (e.g., "Amazon S3", "AWS Lambda", "Amazon EC2" all become "AWS"), but do NOT group unrelated names. Sort the grouped list from most recently used to least recently used, using the order of appearance in the portfolio (highest priority) and then by order of company employment.

EXAMPLE RESPONSE FORMAT:
<p>Sol has <strong>8 years</strong> of professional experience as a DevOps and Cloud Engineer.</p>
<p>His key achievements include:</p>
<ul>
<li>Leading Ansible automation projects</li>
<li>Earning AWS and Azure certifications</li>
</ul>`;

// Allowed origins for CORS (update with your domain)
const ALLOWED_ORIGINS = [
  'https://asoloa.com'
];

/**
 * Validate and sanitize input
 */
function validateInput(body) {
  if (!body || !body.messages || !Array.isArray(body.messages)) {
    throw new Error('Invalid request: messages array is required');
  }

  if (body.messages.length === 0) {
    throw new Error('Invalid request: messages array cannot be empty');
  }

  // Validate each message
  body.messages.forEach((msg, index) => {
    if (!msg.role || !['system', 'user', 'assistant'].includes(msg.role)) {
      throw new Error(`Invalid message at index ${index}: invalid role`);
    }
    if (typeof msg.content !== 'string') {
      throw new Error(`Invalid message at index ${index}: content must be a string`);
    }
    // Limit content length to prevent abuse
    if (msg.content.length > 10000) {
      throw new Error(`Invalid message at index ${index}: content too long`);
    }
  });

  return {
    messages: body.messages,
    maxTokens: Math.min(body.maxTokens || 500, MAX_TOKENS_LIMIT),
    temperature: Math.max(0, Math.min(body.temperature || 0.3, 1)),
    model: DEFAULT_MODEL,
  };
}

/**
 * Get CORS headers
 */
function getCorsHeaders(origin) {
  // Allow specific origins only
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : '';

  return {
    'Access-Control-Allow-Origin': allowedOrigin || '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Content-Type': 'application/json',
  };
}

/**
 * Lambda handler
 */
export const handler = async (event) => {
  const origin = event.headers?.origin || event.headers?.Origin || '';
  const corsHeaders = getCorsHeaders(origin);

  // Handle CORS preflight
  if (event.requestContext?.http?.method === 'OPTIONS' || event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: '',
    };
  }

  try {
    // Parse request body - API Gateway sends body as a string
    let body;
    try {
      // API Gateway Lambda proxy integration sends body as a string
      body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
      
      // Log for debugging
      console.log('Received event:', JSON.stringify(event, null, 2));
      console.log('Parsed body:', JSON.stringify(body, null, 2));
    } catch (error) {
      console.error('Error parsing JSON:', error);
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Invalid JSON in request body' }),
      };
    }

    // Validate input
    let validatedInput;
    try {
      validatedInput = validateInput(body);
    } catch (validationError) {
      console.error('Validation error:', validationError);
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ error: validationError.message }),
      };
    }

    // Insert system prompt at the start of the messages array
    const messagesWithSystemPrompt = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...validatedInput.messages
    ];

    // Get API key from environment
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      console.error('OPENAI_API_KEY environment variable not set');
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'Server configuration error' }),
      };
    }

    // Call OpenAI API
    const openaiResponse = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: validatedInput.model,
        messages: messagesWithSystemPrompt,
        max_tokens: validatedInput.maxTokens,
        temperature: validatedInput.temperature,
      }),
    });

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text();
      console.error('OpenAI API error:', openaiResponse.status, errorText);
      
      return {
        statusCode: openaiResponse.status === 429 ? 429 : 502,
        headers: corsHeaders,
        body: JSON.stringify({ 
          error: openaiResponse.status === 429 
            ? 'Rate limit exceeded. Please try again later.' 
            : 'Error communicating with AI service' 
        }),
      };
    }

    const openaiData = await openaiResponse.json();
    const content = openaiData.choices?.[0]?.message?.content;

    if (!content) {
      return {
        statusCode: 500,
        headers: corsHeaders,
        body: JSON.stringify({ error: 'No response from AI service' }),
      };
    }

    // Return successful response
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        content,
        usage: openaiData.usage, // Include token usage for monitoring
      }),
    };

  } catch (error) {
    console.error('Lambda error:', error);
    
    return {
      statusCode: error.message?.includes('Invalid') ? 400 : 500,
      headers: corsHeaders,
      body: JSON.stringify({ 
        error: error.message || 'Internal server error' 
      }),
    };
  }
};
