// @ts-check

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'DocOps Box SSG Test',
  url: 'https://example.com',
  baseUrl: '/',
  onBrokenLinks: 'warn',
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: false,
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],
};

module.exports = config;
