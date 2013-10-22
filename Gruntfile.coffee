module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-autoprefixer')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-release')

  grunt.config.init
    pkg: grunt.file.readJSON "package.json"
    coffee:
      default:
        files:
          "build/angular-date-range-picker.js": "src/angular-date-range-picker.coffee"
    uglify:
      options:
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
      build:
        src: 'build/<%= pkg.name %>.js'
        dest: 'build/<%= pkg.name %>.min.js'
    release:
      options:
        npm: false
    watch:
      scripts:
        files: ['src/*']
        tasks: ['default']
    less:
      main:
        files:
          "build/angular-date-range-picker.css": "src/angular-date-range-picker.less"
    autoprefixer:
      no_dest:
        src: "build/angular-date-range-picker.css"

  grunt.registerTask "default", ["coffee", "less", "autoprefixer", "uglify"]
