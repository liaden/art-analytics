describe 'tagging routes' do
  context 'has singular resource scope' do
    it 'index' do
      expect(get: '/artwork/tags').to route_to(
        controller: 'tags',
        action:     'index',
        resource:   'artwork'
      )
    end

    it 'does not have a show' do
      expect(get: '/artwork/tags/tag1').to_not route_to(
        controller: 'tags',
        action:     'show',
        resource:   'artwork',
      )
    end

    it 'destroy' do
      expect(delete: '/artwork/tags/tag1').to route_to(
        controller: 'tags',
        action:     'destroy',
        resource:   'artwork',
        id:        'tag1'
      )
    end

    it 'update' do
      expect(put: '/artwork/tags/tag1').to route_to(
        controller: 'tags',
        action:     'update',
        resource:   'artwork',
        id:        'tag1'
      )
    end

    it 'create' do
      expect(post: '/artwork/tags').to route_to(
        controller: 'tags',
        action:     'create',
        resource:   'artwork',
      )
    end

    it 'handles other resource too' do
      expect(get: '/event/tags').to route_to(
        controller: 'tags',
        action:     'index',
        resource:   'event'
      )
    end
  end

  context 'events' do
    it 'has tag index' do
      expect(get: '/events/1/tags').to route_to(
        controller: 'resource_tags',
        action:     'index',
        format:     :json,
        event_id:   '1',
        resource:   'event'
      )
    end

    it 'has tag create' do
      expect(post: '/events/1/tags').to route_to(
        controller: 'resource_tags',
        action:     'create',
        format:     :json,
        event_id:   '1',
        resource:   'event'
      )
    end

    it 'has tag update' do
      expect(put: '/events/1/tags/atag').to route_to(
        controller: 'resource_tags',
        action:     'update',
        format:     :json,
        event_id:   '1',
        resource:   'event',
        id:         'atag'
      )
    end

    it 'has tag destroy' do
      expect(delete: '/events/1/tags/atag').to route_to(
        controller: 'resource_tags',
        action:     'destroy',
        format:     :json,
        event_id:   '1',
        resource:   'event',
        id:         'atag'
      )
    end

    it 'has tag destroy all' do
      expect(delete: '/events/1/tags').to route_to(
        controller: 'resource_tags',
        action:     'destroy_all',
        format:     :json,
        event_id:   '1',
        resource:   'event',
      )
    end
  end

  context 'as its own resource' do
    it 'has an index' do
      expect(get: '/tags').to route_to(
        controller: 'tags',
        action:     'index'
      )
    end
  end
end
