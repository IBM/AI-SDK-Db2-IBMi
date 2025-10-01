import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';


export default defineConfig({
	site: 'https://ibm.github.io',
	base: '/AI-SDK-Db2-IBMi',
	integrations: [
		starlight({
			title: 'A Db2 for i SDK for connecting to various services',
			social: {
				github: 'https://github.com/IBM/AI-SDK-Db2-IBMi/',
			},
			sidebar: [
				{ label: 'Home', link: '/' },
				{
					label: 'IBM watsonx',
					autogenerate: { directory: 'watsonx' }, 
					collapsed: true
				},
				{
					label: 'Ollama',
					autogenerate: { directory: 'ollama' }, 
					collapsed: true
				},
				{
					label: 'OpenAI-compliant endpoints',
					autogenerate: { directory: 'openai' }, 
					collapsed: true
				},
				{
					label: 'Wallaroo',
					autogenerate: { directory: 'wallaroo' }, 
					collapsed: true
				},
				{
					label: 'Kafka',
					autogenerate: { directory: 'kafka' }, 
					collapsed: true
				},
				{
					label: 'PASE',
					autogenerate: { directory: 'pase' }, 
					collapsed: true
				},
				{
					label: 'Slack',
					autogenerate: { directory: 'slack' }, 
					collapsed: true
				},
				{
					label: 'SMS (Twilio)',
					autogenerate: { directory: 'twilio' }, 
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
