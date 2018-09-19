from inputs import get_key
while 1:
    events = get_key()
    for event in events:
        if event.ev_type == 'Key':
            print (event.code, event.state)
