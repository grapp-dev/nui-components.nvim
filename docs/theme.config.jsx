import NuiComponentsLogo from './components/svg/nui-components-logo.svg';

import { Footer, Logo } from '@grapp/nextra-theme';
import { getDefaultConfig } from '@grapp/nextra-theme/config/next';

export default getDefaultConfig({
  title: 'NuiComponents',
  description:
    'A feature-rich and highly customizable library for creating user interfaces in Neovim',
  github: 'https://github.com/grapp-dev/nui-components.nvim',
  discord: 'https://discord.gg/Rj2V3keVS4',
  docs: 'https://nui-components.grapp.dev',
  logo: () => {
    return <Logo image={NuiComponentsLogo} title="nui-components.nvim" />;
  },
  footer: () => {
    return (
      <Footer
        sections={[
          {
            title: 'FAQ',
            links: [
              {
                title: 'What is NuiComponents?',
                url: '/docs#what-is-nuicomponents',
              },
              {
                title: 'Key Features',
                url: '/docs#key-features',
              },
              {
                title: 'About Grapp.Dev',
                url: '/about',
              },
            ],
          },
          {
            title: 'Guides',
            links: [
              {
                title: 'Your first UI implementation',
                url: '/docs/getting-started#your-first-ui-implementation',
              },
              {
                title: 'Discover Signal API',
                url: '/docs/signal#usage-example',
              },
              {
                title: 'Create a new component',
                url: '/docs/component#create-a-new-component',
              },
            ],
          },
        ]}
      />
    );
  },
});
