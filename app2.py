import newrelic.agent
newrelic.agent.initialize('newrelic.ini')

# Existing imports and code

if __name__ == '__main__':
    app.run(debug=True)