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
        'accent': '#00cac6',
        'accent-light': '#00cac6',
        'accent-foreground': '#ffffff',
        'blackish': '#212529',
        'paper': '#ded9d6',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
