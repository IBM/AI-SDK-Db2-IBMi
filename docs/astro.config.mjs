import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';


export default defineConfig({
	site: 'https://ibm.github.io',
	base: '/AI-SDK-Db2-IBMi',
	integrations: [
		starlight({
			title: 'A Db2 for i SDK for connecting to various services',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/IBM/AI-SDK-Db2-IBMi/' },
			],
			sidebar: [
				{ label: 'Home', link: '/' },
				{
					label: 'IBM watsonx',
					items: [{ autogenerate: { directory: 'watsonx' } }],
					collapsed: true
				},
				{
					label: 'Ollama',
					items: [{ autogenerate: { directory: 'ollama' } }],
					collapsed: true
				},
				{
					label: 'OpenAI-compliant endpoints',
					items: [{ autogenerate: { directory: 'openai' } }],
					collapsed: true
				},
				{
					label: 'Wallaroo',
					items: [{ autogenerate: { directory: 'wallaroo' } }],
					collapsed: true
				},
				{
					label: 'Kafka',
					items: [{ autogenerate: { directory: 'kafka' } }],
					collapsed: true
				},
				{
					label: 'PASE',
					items: [{ autogenerate: { directory: 'pase' } }],
					collapsed: true
				},
				{
					label: 'Slack',
					items: [{ autogenerate: { directory: 'slack' } }],
					collapsed: true
				},
				{
					label: 'SMS (Twilio)',
					items: [{ autogenerate: { directory: 'twilio' } }],
					collapsed: true
				},
				{
					label: 'Other Useful links (external)',
					items: [
						// Using `slug` for internal links.
						{ link: 'http://ibm.com', label: "IBM" },
					],
					collapsed: true
				}
			],
			tableOfContents: {
				maxHeadingLevel: 6
			}
		}),
	],
});
