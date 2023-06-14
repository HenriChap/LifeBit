version 1.0 # § versoning control

# ! Before starting, remember to set up your environment with an engine (each with its requirements) and Docker. Suggest starting with cromwell or miniwdl. 

import <path/file/imported.wdl> as imported_wdl # § import syntax makes it possible to recycle components from other workflows, further explored at "Scattered workflow with multiple parameters and plumbing" ! A good practice is to reuse code and improve maintenance. Remember to keep your WDL short.


meta {# § Optional component "meta". For authoring and description. Can be written at multiple parts of the wdl.
   author: "Herique Chapola"
   email: "henriquechapola@gmail.com"
   description:
   "An instructive wdl file for developers, filled with MANY commentaries, for easily finding concepts (' § ') and tips (' ! ').
   Here is described: 
   Simple workflow with a conditional
   Scattered workflow with multiple parameters and plumbing"
 }


# ! For best practice, start your file with the workflow component, containing inputs and tasks. Then describe the task, with inputs, commands, runtime (optional but recommended), and outputs.

workflow basicWorkflow { # § Top-level component "workflow" ! Keep one per wdl file as best practice. Note: in this file, there will be multiple workflows.
  
  meta {
     name: "Simple workflow"
     description: "A simple workflow with one task, called two times, and using all optional components"
  }
  
  parameter_meta{ # § Opitional core-level component "parameter_meta". Use to describe inputs or outputs from workflow and tasks. Names MUST correspond to its section
     my_ref: {
          description: "A reference file",
          pattern:"*.ref"
     }
     my_input: {# ! You can add everything you what. But remember, keep your wdl short and concise.
          description: "Input file",
          any_annotation:"Any observation here",
          
     }

  }
  input { # § Core-level component "input". Hard-type variables as primitive types (String, Boolean, Float, Int, and File) or complex types (Array, Pair, Map, Object)
    File my_ref
    File my_input
    Boolean is_name
    String? name = basename(my_input, ".bam") # ! The "?" set the variable as optional, and "=" set a default value. § basename(), a function with two arguments: where to extract a string, and what to strip off. In this case, the name will be whatever my_input file is named without ".bam" 
}
  if(is_name) { # § WDL only has conditional "if", and takes boolean values to execute the following instruction.
     call task_A as FirstTimeTask {# § Top-level component "call". Call task inputs corresponding to workflows. Input names have to be the same as the task_A description, as shown further. § You can use "as" to alias a task.
          input: 
          ref = my_ref,
          in = my_input,
          id = name     
     }
  }
  if(!is_name) { # § The sign "!" is a modifier to reverse a Boolean value.
     call task_A {# § Top-level component "call". Call task inputs corresponding to workflows.
          input: 
          ref = my_ref,
          in = my_input,
          id = "file" # ! Hard-setted input
     }
  }
}

# ! Describe task(s) after the workflow

task task_A { # § Top-level component "task". Define a programmatic task
  input { #Remember to double-check if input names from this c
    File ref
    File in
    String id
  }
  command <<< # § Core-level component "command". A shell script with your algorithm using "~{}" to add variables
    do_stuff -R ~{ref} -I ~{in} -O ~{id}.ext
  >>>
  runtime { # § Optional core-level "runtime". Set the environment. Attributes may change if you are running wdl file locally or cloud-based. Only local attributes are shown down below
    maxRetries: 0 # § Introduced to provide a method for tackling transient job failures (e.g.: when a task needs an external resource and timeout happen). Setting with an integer to retry te task without the need to re-run the whole workflow
    continueOnReturnCode: 0 # § Set the behavior of the task code returning
    failOnStderr: false # § Set if anything written in standard error stream should fail 
    docker: "ubuntu:latest" # § docker image necessary to run your wdl. ! Some good image repositories are Dockstore, Dockerhub, and quay.io
  }
  output { # § Core-level component "output". Show the expected output. Also hard-typed.
    File out = "~{id}.ext"
  }
}

# Scattered workflow with multiple parameters and plumbing

workflow complexWorkflow { # ! Remember to keep one per wdl file as best practice. Separate workflows in different files
  
  meta {
     name: "Scattered workflow with multiple parameters and plumbing "
     description: "This workflow explores how to deal with and connect multiple inputs and output for greater complexity."
  }
  input{
     Array[File] inputFiles # § Array type needs a complementary type description, as any complex type variable
  }
  scatter ( file in inputFiles) {# § The scatter function alow to parallelize a task. It uses a array to produce an array.
    call imported_wdl.taskA { # § Here is applied the syntax to use taskA from alias imported_wdl . ! If you check the file. taskA has a File type input named "inputFile" and a File type output named "out"
      input: 
        inputFile = file# ! Remember to use the corresponding input name to select the elements of the array
    }
  }
  call imported_wdl.taskB { # "imported_wdl.taskB" has an Array[Files] type input named "files" and File and String type outputs named "out" and "id"
    input: 
      files = imported_wdl.taskA.out # §  As "out" is the name of taskA output, ".out" is the suffix to plumb taskA output to taskB input
  }
  call imported_wdl.taskC { # "imported_wdl.taskC" has File and String type inputs named "inputResults" and "inputId", respectively
    input: 
      inputResults = imported_wdl.taskB.out# ! Multiple input and output plumbing
      inputId = imported_wdl.taskB.id
  }
}
# ! To run your wdl depends on your engine of choice and a JSON mapping the parameters. Explore the documentation.
