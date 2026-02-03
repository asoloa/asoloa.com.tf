/**
 * Chatbot Logic for asoloa.com
 * 
 * Features:
 * - Keyword-based context filtering to reduce token usage
 * - Multi-turn conversation context
 * - Keyboard shortcuts (Enter to send, Escape to minimize)
 * - AWS Lambda proxy support
 * - HTML-formatted responses from LLM
 * 
 * @author Solomon Abejo
 * @version 1.0.0
 */

// ============================================================================
// CONFIGURATION
// ============================================================================
const CHATBOT_CONFIG = {
  // API endpoint - use Lambda proxy in production
  // This placeholder is replaced by GitHub Actions with the actual API endpoint
  apiEndpoint: '__CHATBOT_API_ENDPOINT__',
  
  // UI settings
  tooltipDelay: 1500,
  tooltipDuration: 4000,
  
  // Conversation settings
  maxConversationHistory: 10, // Keep last N messages for context
  maxTokens: 500,
  temperature: 0.3,
};

// ============================================================================
// DATA VALIDATION
// ============================================================================

/**
 * Validate that the knowledgebase has the expected structure
 * @param {Object} kb - The knowledgebase object to validate
 * @returns {boolean} - True if valid, throws error otherwise
 */
function validateKnowledgebase(kb) {
  if (!kb || typeof kb !== 'object') {
    throw new Error('Knowledgebase must be an object');
  }
  
  // Check for required top-level properties
  const requiredSections = ['about', 'portfolio'];
  for (const section of requiredSections) {
    if (!kb[section]) {
      console.warn(`Knowledgebase missing recommended section: ${section}`);
    }
  }
  
  return true;
}

// ============================================================================
// KEYWORD EXTRACTION & CONTEXT FILTERING
// ============================================================================

/**
 * Extract keywords from user question
 */
function extractKeywords(question) {
  const stopWords = new Set([
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could', 'should',
    'may', 'might', 'must', 'shall', 'can', 'need', 'dare', 'ought', 'used',
    'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from', 'as', 'into',
    'through', 'during', 'before', 'after', 'above', 'below', 'between',
    'and', 'but', 'or', 'nor', 'so', 'yet', 'both', 'either', 'neither',
    'not', 'only', 'own', 'same', 'than', 'too', 'very', 'just',
    'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those',
    'i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'you', 'your', 'he', 'him',
    'she', 'her', 'it', 'its', 'they', 'them', 'their',
    'how', 'when', 'where', 'why', 'all', 'each', 'every', 'any', 'some',
    'tell', 'about', 'please', 'thanks', 'thank'
  ]);

  // Add synonyms/related terms mapping
  const synonyms = {
    'job': ['work', 'experience', 'career', 'employment'],
    'work': ['job', 'experience', 'career', 'employment'],
    'experience': ['job', 'work', 'career', 'background'],
    'projects': ['portfolio', 'project', 'work', 'built'],
    'project': ['portfolio', 'projects', 'work', 'built'],
    'skills': ['technologies', 'tools', 'tech', 'stack'],
    'tech': ['technologies', 'tools', 'skills', 'stack'],
    'technologies': ['skills', 'tools', 'tech', 'stack'],
    'certs': ['certifications', 'certification', 'certified'],
    'certification': ['certifications', 'certs', 'certified'],
    'certifications': ['certification', 'certs', 'certified'],
    'school': ['education', 'university', 'college', 'degree'],
    'education': ['school', 'university', 'college', 'degree'],
    'years': ['experience', 'time', 'long', 'duration'],
    'recently': ['current', 'present', 'now', 'latest'],
    'current': ['recently', 'present', 'now', 'latest'],
  };

  const words = question.toLowerCase()
    .replace(/[^\w\s]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 2 && !stopWords.has(word));

  // Expand with synonyms
  const expandedKeywords = new Set(words);
  words.forEach(word => {
    if (synonyms[word]) {
      synonyms[word].forEach(syn => expandedKeywords.add(syn));
    }
  });

  return Array.from(expandedKeywords);
}

/**
 * Score relevance of a section based on keyword matches
 */
function scoreRelevance(item, keywords) {
  let score = 0;
  const itemStr = JSON.stringify(item).toLowerCase();
  
  keywords.forEach(keyword => {
    const regex = new RegExp(keyword, 'gi');
    const matches = itemStr.match(regex);
    if (matches) {
      score += matches.length;
    }
  });
  
  // Check explicit keywords array if present
  if (item.keywords && Array.isArray(item.keywords)) {
    keywords.forEach(keyword => {
      if (item.keywords.some(k => k.toLowerCase().includes(keyword))) {
        score += 3; // Higher weight for explicit keyword matches
      }
    });
  }
  
  return score;
}

/**
 * Build filtered context based on question keywords
 * @param {string} question - The user's question
 * @param {Object} knowledgebase - The knowledgebase object to filter
 * @returns {string} - JSON string of filtered context
 */
function buildFilteredContext(question, knowledgebase) {
  const keywords = extractKeywords(question);
  const context = {};
  
  // Always include basic about info and portfolio if available
  if (knowledgebase.about) {
    context.about = knowledgebase.about;
  }

  if (knowledgebase.portfolio) {
    context.portfolio = knowledgebase.portfolio;
  }
  
  // Score and filter other sections
  const sections = [
    { key: 'services', items: knowledgebase.services },
    { key: 'certifications', items: knowledgebase.certifications },
    { key: 'education', items: knowledgebase.education },
    { key: 'experiences', items: knowledgebase.experiences },
  ];
  
  sections.forEach(section => {
    const scoredItems = section.items
      .map(item => ({ item, score: scoreRelevance(item, keywords) }))
      .filter(scored => scored.score > 0)
      .sort((a, b) => b.score - a.score);
    
    if (scoredItems.length > 0) {
      // Take top relevant items (max 5 per section to save tokens)
      context[section.key] = scoredItems.slice(0, 5).map(s => s.item);
    }
  });
  
  // Always include technologies if asking about skills/tech
  const techKeywords = ['skill', 'tech', 'tool', 'stack', 'technology', 'technologies', 'aws', 'azure', 'service', 'work with', 'use', 'know'];
  if (techKeywords.some(k => question.toLowerCase().includes(k)) && knowledgebase.technologies?.tools) {
    context.technologies = knowledgebase.technologies.tools;
  }
  
  // If no sections matched, include a summary of everything
  if (Object.keys(context).length <= 1) {
    if (knowledgebase.technologies?.tools) {
      context.technologies = knowledgebase.technologies.tools.slice(0, 15);
    }
    if (knowledgebase.certifications) {
      context.certifications = knowledgebase.certifications.map(c => c.certification);
    }
    if (knowledgebase.experiences) {
      context.experiences = knowledgebase.experiences.map(e => ({
        company: e.company,
        position: e.position,
        period: e.period
      }));
    }
  }
  return JSON.stringify(context);
}

// ============================================================================
// CONVERSATION HISTORY
// ============================================================================
let conversationHistory = [];

function addToHistory(role, content) {
  conversationHistory.push({ role, content });
  // Keep only recent messages to limit token usage
  if (conversationHistory.length > CHATBOT_CONFIG.maxConversationHistory) {
    conversationHistory = conversationHistory.slice(-CHATBOT_CONFIG.maxConversationHistory);
  }
}

function getConversationContext() {
  return conversationHistory.map(msg => ({
    role: msg.role,
    content: msg.content
  }));
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function escapeHTML(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

// ============================================================================
// API FUNCTIONS
// ============================================================================

/**
 * Send request to Lambda proxy
 */
async function sendChatRequest(question, context) {
  const messages = [
    { role: 'system', content: `Relevant knowledge about Sol:\n${context}` },
    ...getConversationContext(),
    { role: 'user', content: question }
  ];

  try {
    // Try Lambda proxy first
    const response = await fetch(CHATBOT_CONFIG.apiEndpoint, {
      method: 'POST',
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        messages,
        maxTokens: CHATBOT_CONFIG.maxTokens,
        temperature: CHATBOT_CONFIG.temperature,
      }),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const result = await response.json();
    return result.content || result.choices?.[0]?.message?.content || 'I apologize, but I could not generate a response.';
  } catch (error) {
    console.error('Lambda proxy error:', error);
    throw error;
  }
}

// ============================================================================
// CHATBOT UI LOGIC
// ============================================================================

/**
 * Setup chatbot UI with data dependencies
 * @param {Object} knowledgebase - The knowledgebase object
 * @param {Array<string>} sampleQuestions - Array of sample questions to show
 */
function setupChatbotUI(knowledgebase, sampleQuestions) {
  const chatbot = document.getElementById('asoloa-chatbot');
  const chatbotForm = document.getElementById('chatbot-form');
  const chatbotInput = document.getElementById('chatbot-input');
  const chatbotMessages = document.getElementById('chatbot-messages');
  const minimizeBtn = document.getElementById('chatbot-minimize');
  const fab = document.getElementById('chatbot-fab');
  const tooltip = document.getElementById('chatbot-tooltip');

  let isFirstOpen = true;
  let suggestionsShown = false;
  let isProcessing = false;

  // --- Tooltip Animation ---
  setTimeout(() => {
    tooltip.classList.add('show');
    setTimeout(() => {
      tooltip.classList.remove('show');
    }, CHATBOT_CONFIG.tooltipDuration);
  }, CHATBOT_CONFIG.tooltipDelay);

  // --- Open Chatbot ---
  function openChatbot() {
    chatbot.classList.remove('chatbot-hidden');
    fab.style.display = 'none';
    tooltip.classList.remove('show');
    
    if (isFirstOpen && !suggestionsShown) {
      showSampleQuestions();
      suggestionsShown = true;
    }
    
    isFirstOpen = false;
    chatbotInput.focus();
  }

  // --- Close Chatbot ---
  function closeChatbot() {
    chatbot.classList.add('chatbot-hidden');
    fab.style.display = 'flex';
  }

  // --- Event Listeners ---
  fab.addEventListener('click', openChatbot);
  minimizeBtn.addEventListener('click', closeChatbot);

  // --- Keyboard Shortcuts ---
  document.addEventListener('keydown', (e) => {
    // Escape to minimize
    if (e.key === 'Escape' && !chatbot.classList.contains('chatbot-hidden')) {
      e.preventDefault();
      closeChatbot();
    }
  });

  // --- Sample Questions ---
  function showSampleQuestions() {
    const welcomeMsg = document.createElement('div');
    welcomeMsg.className = 'chatbot-message chatbot-message-bot';
    welcomeMsg.innerHTML = `
      <span class="chatbot-bot-bubble">
        <div class="chatbot-answer">
          <p>${GREETING_MESSAGE}</p>
          <p>Here are some things you can ask:</p>
        </div>
        <div class="chatbot-suggestions">
          ${sampleQuestions.map(q => 
            `<button type="button" class="chatbot-suggestion-btn">${escapeHTML(q)}</button>`
          ).join('')}
        </div>
      </span>
    `;
    chatbotMessages.appendChild(welcomeMsg);

    // Add click handlers for suggestions
    welcomeMsg.querySelectorAll('.chatbot-suggestion-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const question = btn.textContent;
        chatbotInput.value = question;
        handleSubmit(question);
        welcomeMsg.querySelector('.chatbot-suggestions')?.remove();
      });
    });

    chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
  }

  // --- Message Display ---
  function appendMessage(content, sender) {
    const msg = document.createElement('div');
    msg.className = `chatbot-message chatbot-message-${sender}`;

    if (sender === 'user') {
      msg.innerHTML = `<span class="chatbot-user-bubble">${escapeHTML(content)}</span>`;
    } else {
      // Bot messages are already HTML formatted
      msg.innerHTML = `<span class="chatbot-bot-bubble"><div class="chatbot-answer">${content}</div></span>`;
    }

    chatbotMessages.appendChild(msg);
    chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
    return msg;
  }

  function showTypingIndicator() {
    const msg = document.createElement('div');
    msg.className = 'chatbot-message chatbot-message-bot';
    msg.id = 'chatbot-typing';
    msg.innerHTML = `
      <span class="chatbot-bot-bubble">
        <div class="chatbot-typing">
          <span class="chatbot-typing-dot"></span>
          <span class="chatbot-typing-dot"></span>
          <span class="chatbot-typing-dot"></span>
        </div>
      </span>
    `;
    chatbotMessages.appendChild(msg);
    chatbotMessages.scrollTop = chatbotMessages.scrollHeight;
  }

  function removeTypingIndicator() {
    const typing = document.getElementById('chatbot-typing');
    if (typing) typing.remove();
  }

  // --- Submit Handler ---
  async function handleSubmit(question) {
    if (!question.trim() || isProcessing) return;

    isProcessing = true;
    chatbotInput.disabled = true;
    chatbotInput.value = '';

    appendMessage(question, 'user');
    addToHistory('user', question);
    showTypingIndicator();

    try {
      const context = buildFilteredContext(question, knowledgebase);
      const answer = await sendChatRequest(question, context);
      
      removeTypingIndicator();
      appendMessage(answer, 'bot');
      addToHistory('assistant', answer);
    } catch (error) {
      console.error('Chatbot error:', error);
      removeTypingIndicator();
      appendMessage('<p class="error">I apologize, but I encountered an error. Please try again in a moment.</p>', 'bot');
    }

    isProcessing = false;
    chatbotInput.disabled = false;
    chatbotInput.focus();
  }

  // --- Form Submit ---
  chatbotForm.addEventListener('submit', (e) => {
    e.preventDefault();
    handleSubmit(chatbotInput.value.trim());
  });
}

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * Initialize chatbot with data dependencies
 * Expects global variables: kbData, SAMPLE_QUESTIONS
 */
function initChatbot() {
  // Validate data dependencies
  if (typeof kbData === 'undefined') {
    console.error('Chatbot initialization failed: kbData is not defined. Please load chatbot-data.js before chatbot.js');
    return;
  }
  
  if (typeof SAMPLE_QUESTIONS === 'undefined') {
    console.warn('SAMPLE_QUESTIONS is not defined. Using empty array.');
    window.SAMPLE_QUESTIONS = [];
  }
  
  try {
    validateKnowledgebase(kbData);
  } catch (error) {
    console.error('Knowledgebase validation failed:', error);
    return;
  }
  
  if (document.getElementById('chatbot-fab')) {
    setupChatbotUI(kbData, SAMPLE_QUESTIONS);
  } else {
    const root = document.getElementById('chatbot-root');
    if (root) {
      const observer = new MutationObserver(() => {
        if (document.getElementById('chatbot-fab')) {
          setupChatbotUI(kbData, SAMPLE_QUESTIONS);
          observer.disconnect();
        }
      });
      observer.observe(root, { childList: true });
    }
  }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initChatbot);
} else {
  initChatbot();
}
