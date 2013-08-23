module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-copy');
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
        files: ['src/*.coffee']
        tasks: ['coffee']
    copy:
      main:
        files: [
          {expand: true, cwd: 'src/', src: ['*.css'], dest: 'build/', filter: 'isFile'}
        ]

  grunt.registerTask "default", ["coffee", "copy", "uglify"]
