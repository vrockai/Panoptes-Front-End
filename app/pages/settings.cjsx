React = require 'react'
BoundResourceMixin = require '../lib/bound-resource-mixin'
ChangeListener = require '../components/change-listener'
auth = require '../api/auth'
PromiseRenderer = require '../components/promise-renderer'
ImageSelector = require '../components/image-selector'
apiClient = require '../api/client'
putFile = require '../lib/put-file'

MAX_AVATAR_SIZE = 65536

UserSettingsPage = React.createClass
  displayName: 'UserSettingsPage'

  mixins: [BoundResourceMixin]

  boundResource: 'user'

  getDefaultProps: ->
    user: {}

  getInitialState: ->
    avatarError: null

  render: ->
    getAvatarSrc = @props.user.get 'avatar'
      .then ([avatar]) ->
        avatar.src
      .catch ->
        ''

    <div>
      <div className="columns-container">
        <div className="content-container">
          Avatar<br />
          <PromiseRenderer promise={getAvatarSrc} then={(avatarSrc) =>
            placeholder = <div className="form-help content-container">Drop an image here</div>
            <ImageSelector maxSize={MAX_AVATAR_SIZE} ratio={1} defaultValue={avatarSrc} placeholder={placeholder} onChange={@handleAvatarChange} />
          } />
          {if @state.avatarError
            <div className="form-help error">{@state.avatarError.toString()}</div>}
        </div>

        <hr />

        <div className="content-container column">
          <table className="standard-table full">
            <tr>
              <th>Credited name</th>
              <td>
                <input type="text" className="standard-input full" name="credited_name" value={@props.user.credited_name} onChange={@handleChange} />
                <div className="form-help">Public; we’ll use this to give acknowledgement in papers, on posters, etc.</div>
              </td>
            </tr>

            <tr>
              <th>Any other stuff?</th>
              <td>
                TODO
              </td>
            </tr>
          </table>

          <p>
            <button type="button" className="standard-button" disabled={@state.saveInProgress or not @props.user.hasUnsavedChanges()} onClick={@saveResource}>Save profile</button>{' '}
            {@renderSaveStatus()}
          </p>
        </div>
      </div>

      <hr />
      <div className="content-container">
        <p><strong>Email preferences</strong></p>
        <p>TODO</p>
      </div>
    </div>

  handleAvatarChange: (file) ->
    @setState avatarError: null
    apiClient.post @props.user._getURL('avatar'), media: content_type: file.type
      .then ([avatar]) =>
        console.log 'Will put file to', avatar.src
        putFile avatar.src, file
      .then =>
        @props.user.uncacheLink 'avatar'
        @props.user.emit 'change'
      .catch (error) =>
        @setState avatarError: error

module.exports = React.createClass
  displayName: 'UserSettingsPageWrapper'

  render: ->
    <ChangeListener target={auth} handler={=>
      <PromiseRenderer promise={auth.checkCurrent()} then={(user) =>
        if user?
          <UserSettingsPage user={user} />
        else
          <div className="content-container">
            <p>You’re not signed in.</p>
          </div>
      } />
    } />
