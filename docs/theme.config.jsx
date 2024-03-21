import { useRouter } from 'next/router'
import { Logo } from './components/Logo'
import { Footer } from './components/Footer'

export default {
  docsRepositoryBase: 'https://github.com/grapp-dev/nui-components/blob/main/docs',
  head: () => {
    // prettier-ignore
    return (
      <>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="icon" href="/favicon.ico" type="image/x-icon" sizes="48x48" />
        <link rel="apple-touch-icon"  href="/apple-touch-icon.png" sizes="180x180" />
        <meta name="description" content="A feature-rich and highly customizable library for creating user interfaces in Neovim" />
        <meta property="og:title" content="NuiComponents" />
        <meta property="og:description" content="A feature-rich and highly customizable library for creating user interfaces in Neovim" />
        <meta property="og:url" content="https://nui-components.grapp.dev" />
        <meta property="og:image" content="https://nui-components.grapp.dev/og-slogan.png" />
        <meta name="twitter:title" content="NuiComponents" />
        <meta name="twitter:description" content="A feature-rich and highly customizable library for creating user interfaces in Neovim" />
        <meta name="twitter:card" content="summary_large_image" />
        <meta name="twitter:image" content="https://nui-components.grapp.dev/og-slogan.png" />
      </>
    );
  },
  logo: () => <Logo />,
  footer: {
    text: <Footer />,
  },
  project: {},
  feedback: {
    content: null,
  },
  gitTimestamp: null,
  project: {
    link: 'https://github.com/grapp-dev/nui-components.nvim',
  },
  chat: {
    link: 'https://discord.gg/Rj2V3keVS4',
  },
  useNextSeoProps() {
    const { asPath } = useRouter()
    return {
      titleTemplate: asPath !== '/' ? '%s – NuiComponents' : 'NuiComponents',
    }
  },
}
