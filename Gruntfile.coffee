# global module:false 
module.exports = (grunt) ->
  
  coffeeRename = (dest, src)->
    dest + '/' + src.replace(/\.coffee$/, '.js')
  
  # Project configuration.
  grunt.initConfig
    watch:
      tasks: ["coffee"]
      files: ["lib/**/*.coffee", "models/**/*.coffee", "routes/**/*.coffee", "config/**/*.coffee"]
      options:
        spawn: false

    coffee:
      compile:
        files: [
          {expand: true, cwd: 'config', src: ['**/*.coffee'], dest: 'config', rename: coffeeRename}
          {expand: true, cwd: 'models', src: ['**/*.coffee'], dest: 'models', rename: coffeeRename}
          {expand: true, cwd: 'lib', src: ['**/*.coffee'], dest: 'lib', rename: coffeeRename}
          {expand: true, cwd: 'routes', src: ['**/*.coffee'], dest: 'routes', rename: coffeeRename}
        ]

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-watch"
  
  # Default task.
  grunt.registerTask "default", "coffee"