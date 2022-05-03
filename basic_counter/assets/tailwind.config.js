const defaultTheme = require('tailwindcss/defaultTheme')
// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Averta', 'HelveticaNeue', ...defaultTheme.fontFamily.sans],
        'poppins': ['Poppins', 'HelveticaNeue', ...defaultTheme.fontFamily.sans]
      },
      colors: {
        'primary': '#2d3343',
        'accent': '#00B0AD',
        'accent-light': '#00cac6',
        'accent-dark': '#009794',
        'accent-foreground': '#ffffff',
        'blackish': '#212529',
        'blackish-invert': '#e4e5e6',
        'whiteish': '#f6f8fa',
        'whiteish-invert': '#2d3343',
        'paper': '#ded9d6',
      },
      typography: (theme) => ({
        DEFAULT: {
          css: {
            '--tw-prose-links': theme('colors.accent'),
            '--tw-prose-invert-links': theme('colors.accent')
          }
        }
      })
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ]
}
