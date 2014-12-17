React = require 'react'
ChangeListener = require '../components/change-listener'
SubjectViewer = require './subject-viewer'
TaskViewer = require './task-viewer'

module.exports = React.createClass
  displayName: 'Classifier'

  getInitialState: ->
    selectedDrawingTool: @getTask()?.tools?[0]

  getAnnotation: ->
    @props.classification.annotations[@props.classification.annotations.length - 1]

  getTask: ->
    @props.workflow.tasks[@getAnnotation().task]

  render: ->
    <ChangeListener target={@props.classification} eventName="change" handler={@renderClassification} />

  renderClassification: ->
    annotation = @getAnnotation()
    task = @props.workflow.tasks[annotation.task]
    currentTool = @state.selectedDrawingTool

    <div className="project-classify-page">
      {@renderSubject annotation, currentTool}
      {@renderTaskArea annotation, task, currentTool}
    </div>

  renderSubject: (annotation, currentTool) ->
    <div className="subject">
      <SubjectViewer subject={@props.subject} classification={@props.classification} annotation={annotation} selectedDrawingTool={currentTool} />
    </div>

  renderTaskArea: (annotation, task, currentTool) ->
    onFirstTask = @props.classification.annotations.length is 1
    needsAnswer = task.required and not annotation.answer?
    nextTaskKey = annotation._answer?.next ? task.next
    canGoForward = needsAnswer or nextTaskKey?

    <div className="classifier-task">
      <TaskViewer task={task} annotation={annotation} selectedDrawingTool={currentTool} onChange={@handleAnswer} />

      <div className="task-nav">
        <button className="backward" disabled={onFirstTask} onClick={@previousTask}><i className="fa fa-arrow-left"></i></button>

        {if canGoForward
          <button className="forward" disabled={needsAnswer} onClick={@loadTask.bind this, nextTaskKey}>Next <i className="fa fa-arrow-right"></i></button>
        else
          <button className="forward" disabled={needsAnswer} onClick={@finishClassification}>Finished <i className="fa fa-check"></i></button>}
      </div>
    </div>

  handleAnswer: (e, answer) ->
    switch @getTask().type
      when 'drawing'
        @setState selectedDrawingTool: answer
      else
        @getAnnotation().answer = answer.value
        @getAnnotation()._answer = answer
        @props.classification.emit 'change'

  loadTask: (task) ->
    @props.classification.annotations.push {task}
    @props.classification.emit 'change'

  previousTask: ->
    @props.classification.annotations.pop()
    @props.classification.emit 'change'
    @setState selectedDrawingTool: @getTask().tools?[0]

  finishClassification: ->
    alert 'TODO: Save the classification and get the next subject.'
