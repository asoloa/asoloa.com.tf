/**
 * Knowledgebase Data for asoloa.com Chatbot
 * 
 * This file contains the knowledgebase content that the chatbot uses to answer questions.
 * The structure is designed to be keyword-searchable and filterable.
 * 
 * @author Solomon Abejo
 * @version 1.0.0
 */

// Greeting message on chatbot open
const GREETING_MESSAGE = "👋 Hi! I am AI AMBot (About Me Bot), Sol's work AI assistant. I can answer questions about Sol's experience, skills, projects, and background.";

// Sample questions to suggest on first open
const SAMPLE_QUESTIONS = [
  "What are some personal projects Sol has worked on?",
  "What technologies did Sol work on recently?",
  "What certifications does Sol have?",
  "What are Sol's AI-related projects?",
  "List Sol's personal links.",
];

// Main knowledgebase structure
const kbData = {
  about: {
    name: "Solomon Abejo",
    nickname: "Sol",
    title: "DevOps and Cloud Engineer",
    location: "Cebu City, Philippines",
    summary: "DevOps and Cloud Engineer with years of experience turning complex problems into clean, automated solutions. Has worked across diverse teams in the Philippines and beyond, leading automation projects, delivering internal training sessions, and solving production issues with a mix of solid engineering and practical problem-solving.",
    links: [
      { label: "GitHub", url: "https://github.com/asoloa"},
      { label: "LinkedIn", url: "https://www.linkedin.com/in/abejo-solomon/" },
      { label: "Email", url: "soloabejo@gmail.com"},
      { label: "Resume", url: "https://bit.ly/asoloa-cv" }
    ]
  },
  portfolio: [
    {
      title: "asoloa.com: Personal Website",
      description: "A fully serverless web application with an AI chatbot, using a cloud-native architecture utilizing multiple AWS services, with everything automatically provisioned via Terraform, source-controlled with GitHub, and with changes automatically deployed via GitHub Actions with AWS CLI and Ansible.",
      link: "https://github.com/asoloa/asoloa.com",
      keywords: ["website", "serverless", "aws", "terraform", "github", "ansible", "project", "ai", "chatbot", "openai"],
      technologies: 'aws, amazon, ansible, terraform, github, github actions, amazon lambda, amazon api gateway, aws s3, amazon cloudfront, openai, ai chatbot, chatbot,ai'
    },
    {
      title: "asoloa.com.tf: Terraform Project for Personal Website",
      description: "IaC solution for asoloa.com, with everything built and run on the cloud.",
      link: "https://github.com/asoloa/asoloa.com.tf",
      keywords: ["terraform", "iac", "infrastructure", "aws", "cloud", "project", "ai", "chatbot", "openai"],
      technologies: 'aws, amazon, ansible, terraform, github, github actions, amazon lambda, amazon api gateway, aws s3, amazon cloudfront, openai, ai chatbot, chatbot, ai'
    },
    {
      title: "AI AMBot: AI Chatbot for Personal Website",
      description: "AI-powered chatbot integrated into asoloa.com, built using AWS Lambda, API Gateway, and OpenAI to provide dynamic responses about my background and projects.",
      link: "https://github.com/asoloa/asoloa.com.tf",
      keywords: ["ai", "chatbot", "openai", "aws", "lambda", "api gateway", "project"],
      technologies: 'aws, amazon, amazon lambda, amazon api gateway, openai, ai chatbot, chatbot, ai'
    },
    {
      title: "PowerShell Calendar Report Generator",
      description: "VBA Macro converted to a modern and automated PowerShell solution for transforming timesheet data into a calendar-style Excel report. It leverages PowerShell and Excel COM automation for fast, in-memory data processing and clean, professional output.",
      link: "https://github.com/asoloa/learn-powershell/tree/main/WorkCalendar",
      keywords: ["powershell", "excel", "vba", "automation", "report", "project"],
      technologies: 'excel vba, powershell'
    },
    {
      title: "gcommit",
      description: "CLI tool and Git hook that generates Conventional Commits using OpenAI API. Includes a Python script that estimates the tokens to be consumed by the input.",
      link: "https://github.com/asoloa/gcommit",
      keywords: ["cli", "git", "openai", "python", "automation", "commits", "project"],
      technologies: 'bash, git, openai, python, tiktoken, ai'
    }
  ],
  technologies: {
    tools: [
      'Amazon API Gateway', 'Amazon CloudFront', 'Amazon CloudWatch', 'Amazon DynamoDB', 
      'Amazon EC2', 'Amazon GuardDuty', 'Amazon RDS', 'Amazon S3', 'Amazon VPC', 
      'AWS Cert Manager', 'AWS DMS', 'AWS IAM', 'AWS Lambda', 
      'Ansible', 'Terraform', 'Bash', 'PowerShell', 'Excel VBA', 'GitHub Actions', 'Git',
      'OpenAI API', 'AI', 'OpenStack', 'OpenShift', 'Docker', 'Kubernetes', 'Linux KVM',  'GitHub', 'Linode',
      'Java', 'PHP', 'VueJS', 'Vagrant', 'MySQL', 'GitLab', 'Jira', 'Redmine', 
      'Asterisk', 'SendGrid', 'Slack'
    ],
    keywords: ["technology", "technologies", "tool", "skill", "stack", "tech", "experience", "exp"]
  },
  certifications: [
    {
      certification: 'Microsoft Azure Fundamentals',
      period: 'SEP 2024',
      credential: '5C8BCF4D13DED222',
      keywords: ["azure", "microsoft", "cloud", "certification", "cert"]
    },
    {
      certification: 'AWS Certified Solutions Architect - Associate',
      period: 'DEC 2019 - DEC 2022',
      credential: 'NW06RPW1F2BEQ4GZ',
      keywords: ["aws", "architect", "cloud", "certification", "cert"]
    },
    {
      certification: 'AWS Certified Cloud Practitioner',
      period: 'JUN 2019 - JUN 2022',
      credential: '450Y3S02B14E1J3W',
      keywords: ["aws", "cloud", "practitioner", "certification", "cert"]
    },
    {
      certification: 'ITPEC/PhilNITS Fundamental Information Technology Engineer',
      period: 'OCT 2019',
      credential: '',
      keywords: ["itpec", "philnits", "engineer", "certification", "cert"]
    },
    {
      certification: 'Japanese Language Proficiency Test - N5 Level',
      period: 'JUL 2019',
      credential: '',
      keywords: ["japanese", "jlpt", "language", "certification", "cert"]
    }
  ],
  education: [
    {
      school: 'Cebu Institute of Technology - University',
      location: 'Cebu City, Philippines',
      degree: 'Bachelor of Science in Computer Engineering',
      period: 'OCT 2017',
      keywords: ["education", "university", "degree", "college", "school", "cit"]
    }
  ],
  experiences: [
    {
      company: 'WeServ Systems International, Inc. | Fujitsu',
      location: 'Cebu City, Philippines',
      position: 'Technology Support Engineer',
      period: 'DEC 2021 - PRESENT',
      description: [
        'Project Lead and main reviewer of an Ansible automation project: developed and maintained Ansible roles to automate the setup and configuration of proprietary HA cluster applications',
        'Conducted Ansible trainings to our Service Line\'s 20+ engineers to raise overall technical maturity',
        'Created comprehensive and meticulous technical documentation detailing the logic and process flows of Ansible playbooks and roles for the consumption of our Japanese counterparts',
        'Developed Excel VBA tools initially integrated with REST APIs then switched to text/file parsers to support OpenStack/OpenShift usage billing automation',
        'Initiated an Excel VBA solution that parsed SAP-exported timesheets into calendar view, improving managerial oversight and increasing trust in reported work hours',
        'Awarded The Best Performer Award for outstanding technical execution and delivery results within our Global Delivery Unit, spanning China, India, Malaysia, and the Philippines',
        'Consistently received high ratings on Partner Performance Reviews for exemplary project performance and customer satisfaction'
      ],
      tools: 'Ansible, Linux, Git, Bash, RegEx, Excel VBA, PowerShell, OpenStack, OpenShift',
      keywords: ["weserv", "current", "present", "job", "work", "experience", "ansible", "lead", "award"]
    },
    {
      company: 'Lanex Philippines',
      location: 'Cebu City, Philippines',
      position: 'DevOps Engineer',
      period: 'APR 2021 - DEC 2021',
      description: [
        'Resolved infrastructure and application downtime issues by identifying the gaps in the configuration; implementing automated monitoring, alerting, and security countermeasures',
        'Configured and maintained Asterisk/VICIdial dial plans (CTI), integrating with CRM built on VueJS (frontend) and PHP (backend) for call center operations',
        'Led the initiative to document project processes to accelerate the onboarding and knowledge acquisition of new team members',
        'Onboarded and provisioned accounts and access of new employees to company resources using Google Admin',
      ],
      tools: 'Asterisk, VICIdial, Ansible, Linode, Amazon EC2, Linux, Git, Bash, VueJS, PHP, MySQL, RegEx, cron, iptables, fail2ban, SendGrid, UptimeRobot, Jira, Google Admin',
      keywords: ["lanex", "devops", "job", "work", "experience", "asterisk", "call center"]
    },
    {
      company: 'NEC Telecom Software Philippines, Inc.',
      location: 'Cebu City, Philippines',
      position: 'Software Design Engineer I-III',
      period: 'FEB 2018 - APR 2021',
      description: [
        'Developed Ansible playbooks that automate the provisioning of a highly available infrastructure and application on Linux KVM',
        'Explored and deployed various open-source tools for proof-of-concepts with basic operations, issue resolution, and infrastructure automation',
        'Authored multiple detailed documentations on common AWS services and open-source software, with use-cases',
        'Conducted peer reviews of automation code (Ansible & Jenkins) and contributed to CICD improvements',
        'Recognized with multiple Presidential Awards',
        'Passed multiple certifications',
      ],
      tools: 'Ansible, AWS, Linux KVM and Networking, Bash, Git, Gitlab, OpenStack, Docker, Kubernetes, Vagrant, Robot Framework, Excel VBA, RegEx, OpenvSwitch, Calico CNI, Samba, LDAP',
      keywords: ["nec", "software", "engineer", "job", "work", "experience", "aws", "docker", "kubernetes", "first job"]
    }
  ]
};
