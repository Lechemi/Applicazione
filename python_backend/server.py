from flask import Flask, request, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
import backend as b
import jwt
import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecret'
credentials = dict()
subjectNames = ['Italiano', 'Inglese', 'Filosofia', 'Storia', 'Matematica', 'Informatica', 'Fisica', 'Scienze', 'Arte', 'Educazione Fisica']

@app.route('/login', methods=['POST'])
# Qua posto le credenziali nel body della richiesta e il server mi dà il token per ottenere le informazioni
def getCredentials():
    username = request.get_json(force=True).get('username')
    password = request.get_json(force=True).get('password')
    # Genero un token usando username, secret key e bla bla bla
    token = jwt.encode({'user': username, 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)}, app.config['SECRET_KEY'])
    # Metto il token come key e come value metto un dizionario contenente username e psw nel dizionario credentials (dichiarato sopra)
    credentials[token.decode('UTF-8')] = {'username': username, 'password': password}
    return jsonify({'token': token.decode('UTF-8')}) #ritorno il token

@app.route ('/creds', methods=['GET'])
# Totalmente opzionale: ottengo le credenziali
def creds():
    return jsonify({'credentials': credentials})

@app.route('/api', methods=['GET'])
def api():
    # Qua uso il token per ottenere le credenziali associate al token creato 
    if request.method == 'GET':
        token = None #"azzero" il token in modo da non usare quello già salvato nella variabile
        # Se c'è il token nelle headers, lo salvo
        if 'x-access-token' in request.headers:
            token = request.headers['x-access-token']

        # Se non c'è il token
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403

        try:
            # Provo a decodificare il token usando la secret key
            jwt.decode(token, app.config['SECRET_KEY'])
            creds = credentials.get(token)
            #return jsonify({'creds': creds})
        except:
            # Se non funziona, il token è incorretto
            return jsonify({'message': 'Incorrect token!'}), 403

        d = {}
        # Creo la sessione con username e password
        requestSession = b.login(creds['username'], creds['password'])
        query = str(request.args['query'])
        try:
            if query == 'marks':
                m = b.getFullMarks(requestSession)
                for i in range(len(subjectNames)):
                    d[subjectNames[i]] = m[i]
                return jsonify(d)
            elif query == 'names':
                m = b.getNames(requestSession)
                return jsonify(m)
            elif query == 'calendar':
                m = b.calendar(requestSession)
                d['Calendar'] = m
                return jsonify(d)
            elif query == 'badge':
                m = b.badge(requestSession)
                d['Badge'] = m
                return jsonify(d)
            elif query == 'userdetails':
                m = b.getUserDetails(requestSession)
                d['Name'] = m[0]
                d['Class'] = m[1]
                return jsonify(d)
        except:
            return jsonify({'message': 'invalid credentials'}), 500

if __name__ == '__main__':
    app.run()


