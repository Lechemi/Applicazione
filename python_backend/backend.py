import requests
from bs4 import BeautifulSoup
#VEDIAMO SE FUNZIONA GITHUB

link = "https://nuvola.madisoft.it/login"
post_url = "https://nuvola.madisoft.it/login_check"
grades = '/area_tutore/voto/situazione'
call = '/area_tutore/assenza/report'
week = '/area_tutore/argomento_lezione/form/visuale-settimanale'
prefix = 'https://nuvola.madisoft.it'


def dateManager(month, year):
    if month == 2 and year%4 == 0:
        days = 29
    elif month == 2 and year%4 != 0:
        days = 28
    elif month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12:
        days = 31
    else:
        days = 30
    return days


def next_month(day, monday, month):
    if day < monday:
        return month + 1
    else:
        return month

def switch_month(day, max_days, increment):
    if day + increment > max_days:
        day = (day + increment)-max_days
    else:
        day = day + increment
    return day

def zerodate(data):
    if type(data) == int:
        if data/10 < 1:
            return str('-0' + str(data))
        else:
            return str('-' + str(data))
    else:
        if data[0] == '0':
            return int(data[1])
        else:
            return int(data) 

def organize(details, n_marks):
    grades = list()
    for i in range(n_marks):
        # 5 perché la lista di dettagli per ogni voto comprende 5 informazioni
        grade = details[i*5:(i+1)*5]
        grades.append(grade)
    return grades


def convertMarks(text):
    try:
        mark = float(text)
    except ValueError:
        mark = text
        if mark == '2½':
            mark = 2.5
        elif mark == '3½':
            mark = 3.5
        elif mark == '4½':
            mark = 4.5
        elif mark == '5½':
            mark = 5.5
        elif mark == '6½':
            mark = 6.5
        elif mark == '7½':
            mark = 7.5
        elif mark == '8½':
            mark = 8.5
        elif mark == '9½':
            mark = 9.5
    return mark

def lowerCase(nome):
    # Dato COGNOME NOME ritorna Nome Cognome (ad esempio: dato CERONI MICHELE ritorna Michele Ceroni)
    nome = nome.lower()
    fullNome = nome.split()
    for n in range(len(fullNome)):
        fullNome[n] = fullNome[n].capitalize()
    fullNome.insert(0, fullNome[-1])
    fullNome.pop()
    nome = ' '.join(fullNome)
    return nome


def login(username, password):
    s = requests.Session()
    r = s.get(link, headers={"User-Agent": "Mozilla/5.0"})
    soup = BeautifulSoup(r.text, "html.parser")
    payload = {i['name']: i.get('value', '') for i in soup.select('input[name]')}
    payload['_username'] = username
    payload['_password'] = password
    cookie = r.headers['set-cookie'].split(" ")[0]
    s.post(post_url, data=payload, headers={
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'max-age=0',
        'Connection': 'keep-alive',
        'Content-Length': '96',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': '_ga=GA1.3.99501944.1555252666; ' + str(cookie),
        'Host': 'nuvola.madisoft.it',
        'Origin': 'https://nuvola.madisoft.it',
        'Referer': 'https://nuvola.madisoft.it/login',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'same-origin',
        'Sec-Fetch-User': '?1',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36'
    })
    return s

        
def getFullMarks(session):
    # ACCESSO ALLA SITUAZIONE GENERALE
    marks = list()

    r = session.get(prefix + grades)
    soup = BeautifulSoup(r.text, features='lxml')

    for subject in soup.findAll('tr'):
        # PER OGNI MATERIA
        l = list()
        justifyNumber = 0
        n_grades = len(subject.findAll('span', class_='dato'))
        for grade in subject.findAll('span', class_='dato'):
            # PER OGNI VOTO
            for link in grade.findAll('a'):
                # PER OGNI LINK
                if link.find('span', class_='valore').text == 'G':
                    justifyNumber += 1
                    n_grades -= 1
                else:
                    show_grade = link.get('href')
                    rshow = session.get(prefix + show_grade)
                    grade_soup = BeautifulSoup(rshow.text, features='lxml')
                    if len(grade_soup.findAll('tr')) == 8:
                        not_average = True
                    else:
                        not_average = False
                    info_counter = 0
                    for info in grade_soup.findAll('tr'):
                        # PER OGNI DETTAGLIO SUL VOTO
                        if info_counter != 0 and info_counter != 3 and info_counter != 6 and info_counter != 2:
                            if info_counter == 5:
                                value = info.find('td').text
                                m = convertMarks(value)
                                l.append(m)
                                if not_average:
                                    l.append('NO')
                            else:
                                m = info.find('td').text
                                l.append(m)
                        info_counter += 1
        # Suddivido la lista di dettagli in tante liste quanti sono i voti
        l = organize(l, n_grades) #Qua l passa da lista, a lista di liste
        l.append(justifyNumber)
        # Aggiungo la lista singola alla lista generale
        marks.append(l)
    return marks

def getNames(session):

    infoCounter = 0
    names = {'Italiano': '', 'Inglese': '', 'Filosofia': '', 'Storia': '', 'Matematica': '', 'Informatica': '', 'Fisica': '', 'Scienze': '', 'Arte': '', 'Educazione Fisica': ''}

    # ACCESSO ALLA VISUALIZZAZIONE SETTIMANALE
    r = session.get(prefix + week)
    soup = BeautifulSoup(r.text, features='lxml')

    # TROVO IL GIORNO DEL LUNEDI' PASSATO PIU' VICINO (first_day)
    s = soup.find('h2', class_='text-center').text
    s_data = s[:-20]
    s_data = s_data.translate({ord(i): None for i in 'abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -ì'})
    if len(s_data) == 6:
        first_day = int(s_data[:2])
        year = int(s_data[2:])
    else:
        first_day = int(s_data[0])
        year = int(s_data[1:])

    # TROVO IL MESE CORRENTE
    for thing in soup.findAll('input'):
        if thing.get('id') == 'scelta_giorno_data':
            date_string = thing.get('value')
            currentMonth = zerodate(date_string[3:5])
            break

    # posso andare alla settimana precedente (a meno che non è la prima settimana di scuola) e prendere i nomi, 
    # dalla seconda settimana in poi, ogni volta che prendo i nomi, li confronto con il dizionario che ho creato durante la prima settimana.
    # per ogni nome, se è diverso dal precedente o se il precedente non c'era, modifico il dizionario; se il nome c'è già e nel nuovo dizionario manca,
    # non faccio modifiche

    y_string = str('/' + str(year))
    d_string = zerodate(first_day)
    m_string = zerodate(currentMonth)
    full_string_date = y_string + m_string + d_string

    if first_day-7 > 0:
        # se la settimana prima rientra nello stesso mese
        first_day -= 7
    else:
        # se la settimana prima non rientra nello stesso mese
        remainingDays = 7 - first_day
        if currentMonth - 1 > 0:
            # se il mese prima rientra nello stesso anno
            currentMonth -= 1
            monthDays = dateManager(currentMonth, year)
            first_day = monthDays - remainingDays
        else: 
            # se il mese prima non rientra nello stesso anno (vado a dicembre)
            year -= 1
            currentMonth = 12
            monthDays = 31
            first_day = monthDays - remainingDays


    y_string = str('/' + str(year))
    d_string = zerodate(first_day)
    m_string = zerodate(currentMonth)
    full_string_date = y_string + m_string + d_string

    r = session.get(prefix + week + full_string_date)
    soup = BeautifulSoup(r.text, features='lxml')

    for row in soup.findAll('tr'):
        for line in row.findAll('td'):
            if line.text != '':
                try:
                    int(line.text)
                except ValueError:
                    if infoCounter == 2:
                        name = line.text
                    elif infoCounter == 3:
                        if line.text == 'LINGUA E LETTERATURA ITALIANA':
                            names['Italiano'] = name
                        elif line.text == 'LINGUA E CULTURA STRANIERA - INGLESE':
                            names['Inglese'] = name
                        elif line.text == 'FILOSOFIA':
                            names['Filosofia'] = name
                        elif line.text == 'STORIA':
                            names['Storia'] = name
                        elif line.text == 'MATEMATICA':
                            names['Matematica'] = name
                        elif line.text == 'INFORMATICA':
                            names['Informatica'] = name
                        elif line.text == 'FISICA':
                            names['Fisica'] = name
                        elif line.text == 'SCIENZE NATURALI (BIOLOGIA, CHIMICA, SCIENZE DELLA TERRA)':
                            names['Scienze'] = name
                        elif line.text == 'DISEGNO E STORIA DELL\'ARTE':
                            names['Arte'] = name
                        elif line.text == 'SCIENZE MOTORIE E SPORTIVE':
                            names['Educazione Fisica'] = name
                    if infoCounter < 3:
                        infoCounter += 1
                    else: 
                        infoCounter = 0
    # Per ogni insegnante trasformo il nome usando lowercase()
    for key in names:
        if names[key] != '':
            names[key] = lowerCase(names[key])

    return names


def badge(session):

    # ACCEDO ALL'AREA ASSENZE
    r = session.get(prefix + call)
    soup = BeautifulSoup(r.text, features='lxml')
    body = soup.find('tbody')
    full_assenze = []
    for month in body.findAll('tr'):
        for day in month.findAll('td'):
            for span in day.findAll('span'):
                for link in span.findAll('a'):
                    # TROVO TUTTI I LINK CHE PORTANO AI DETTAGLI E ACCEDO AD ESSI
                    rshow = session.get(prefix + link.get('href'))
                    rsoup = BeautifulSoup(rshow.text, features='lxml')
                    info_counter = 0
                    assenza = []
                    # assenza contiene tutti i dati relativi ad ogni singola assenza/ritardo/uscita
                    for detail in rsoup.findAll('td'):
                        # PER OGNI INFORMAZIONE RIGUARDO L'ASSENZA/RITARDO/USCITA
                        if info_counter == 1:
                            assenza.append(detail.text)
                        elif info_counter == 3:
                            assenza.append(detail.text.lower().capitalize())
                            tipo = 2
                            if detail.text == 'RITARDO':
                                tipo = 0
                            elif detail.text == 'USCITA':
                                tipo = 1
                            else:
                                tipo = 2
                                pass
                        elif info_counter == 4 and tipo == 0:
                            assenza.append(detail.text)
                        elif info_counter == 5 and tipo == 1:
                            assenza.append(detail.text)
                        elif info_counter == 7:
                            assenza.append(detail.text)
                            if detail.text == 'SI':
                                giustifica = True
                            else:
                                giustifica = False
                        elif info_counter == 8 and giustifica:
                            assenza.append(detail.text.lower())
                        elif info_counter == 9 and giustifica:
                            assenza.append(detail.text.lower())
                        else:
                            pass
                        info_counter += 1
                    full_assenze.append(assenza)
    return full_assenze 

def calendar(session):

    # ACCESSO ALLA VISUALIZZAZIONE SETTIMANALE
    r = session.get(prefix + week)
    soup = BeautifulSoup(r.text, features='lxml')
    full_calendar = []

    # TROVO IL GIORNO DEL LUNEDI' PASSATO PIU' VICINO (first_day)
    s = soup.find('h2', class_='text-center').text
    s_data = s[:-20]
    s_data = s_data.translate({ord(i): None for i in 'abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -ì'})
    if len(s_data) == 6:
        first_day = int(s_data[:2])
        year = int(s_data[2:])
    else:
        first_day = int(s_data[0])
        year = int(s_data[1:])

    # TROVO IL MESE CORRENTE
    for thing in soup.findAll('input'):
        if thing.get('id') == 'scelta_giorno_data':
            date_string = thing.get('value')
            currentMonth = zerodate(date_string[3:5])
            break

    n_days = dateManager(currentMonth, year)
    y_string = str('/' + str(year))
    # ACCEDO AD OGNI SETTIMANA E PRENDO COMPITI E VERIFICHE (decido quante settimane osservare in base al range)
    for i in range(4):
        d_string = zerodate(first_day)
        m_string = zerodate(currentMonth)
        full_string_date = y_string + m_string + d_string
        r = session.get(prefix + week + full_string_date)
        soup = BeautifulSoup(r.text, features='lxml')

        # PRENDO I COMPITI E LE RISPETTIVE DATE/MATERIE
        for table in soup.findAll('table'):
            if table.get('id') != 'registro-di-classe-griglia-argomenti':
                due = ''
                full_h_details = []
                days_counter = 0
                for homework in table.findAll('tr'):
                    try:
                        if homework.get('class')[0] == 'titoloData':
                            due = due + homework.text
                            homework_counter = 0
                            days_counter += 1
                        elif homework.get('class')[0] == 'oggi':
                            homework.get('class')[10]
                    except IndexError:
                        if homework_counter == 0:
                            homework_counter += 1
                        else:
                            # RICAVO TUTTE LE INFORMAZIONI PER OGNI COMPITO
                            h_details = homework.findAll('td')
                            c = 0
                            for i in h_details:
                                if c == 0:
                                    h_details[c] = i.text.lower()
                                elif c == 1:
                                    if i.text.strip() == '':
                                        addList = False
                                    else: 
                                        addList = True
                                        h_details[c] = i.text
                                else:
                                    h_details[c] = i.text
                                c += 1
                            h_details.append(int(days_counter/2))
                            del h_details[3]
                            if addList:
                                full_h_details.append(h_details)
                            homework_counter += 1
                # Ho una lista contenente i dettagli di ogni compito (full_h_details)
                due = due.translate({ord(i): None for i in 'abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-ì: '}).strip()
                due = due.split()
                c = 0
                for i in due:
                    if len(i) == 6:
                        due[c] = int(i[:2])
                        due[c] = zerodate(due[c]) + zerodate(next_month(due[c], int(first_day), int(currentMonth))) + zerodate(year)
                        due[c] = due[c][1:].split('-')
                        for i in range(len(due[c])):
                            due[c][i] = int(due[c][i])
                    else:
                        due[c] = int(i[0])
                        due[c] = zerodate(due[c]) + zerodate(next_month(due[c], int(first_day), int(currentMonth))) + zerodate(year)
                        due[c] = due[c][1:].split('-')
                        for i in range(len(due[c])):
                            due[c][i] = int(due[c][i])
                    c += 1
                # Ho una lista contenente le date di ogni compito (due)
                fullfull_h_details = []
                for i in range(len(due)):
                    for j in full_h_details:
                        if j[-1] == (i+1):
                            j.remove(i+1)
                            fullfull_h_details.append('Homework')
                            fullfull_h_details.append(due[i])
                            for y in j:
                                fullfull_h_details.append(y)
                # Ho una lista che ha il numero del giorno seguito da una lista contenente i compiti di quel giorno (fullfull_h_details)
                
        # VERIFICHE e ASSEGNAZIONE DATE
        giorno = 0
        test_details = []
        for row in soup.findAll('tr'):
            # PER OGNI ORA DELLA SETTIMANA
            for line in row.findAll('td'):
                # PER OGNI INFORMAZIONE CIRCA OGNI ORA
                if line.text == '1':
                    giorno += 1
                    day = switch_month(first_day, n_days, (giorno-1))
                    # day è il giorno della settimana in cui mi trovo
                    test = False
                    info_counter = 0
                elif line.text == '6':
                    # Da cambiare se ci sono più di 6 ore
                    break
                elif line.text == 'Compito in classe':
                    test = True
                    test_details.append('Test')
                    try: 
                        if test_details[-1] == 'Test' and test_details[-2] == 'Test':
                            del test_details[-1]
                    except IndexError:
                        pass
                if test and info_counter != 4:
                    info_counter += 1
                    if info_counter == 2:
                        test_desc = (line.text.strip())
                        test_date = zerodate(day) + zerodate(next_month(day, int(first_day), int(currentMonth))) + zerodate(year)
                        test_date = test_date.replace('-', '/')[1:]
                        test_date = test_date.split('/')
                        for i in range(len(test_date)):
                            test_date[i] = int(test_date[i])
                        test_details.append(test_date)
                        test_details.append(test_desc)
                    elif info_counter == 4:
                        test_details.append(line.text.lower())

        # METTO I COMPITI NELLA LISTA FINALE DELLE SETTIMANE
        if len(fullfull_h_details) != 0:
            for i in fullfull_h_details:
                full_calendar.append(i)
        if len(test_details) != 0:
            for i in test_details:
                full_calendar.append(i)

        # CAMBIO MESE SE NECESSARIO
        if switch_month(first_day, n_days, 7) < first_day + 7:
            first_day = switch_month(first_day, n_days, 7)
            n_days = dateManager(currentMonth+1, year)
            currentMonth += 1
        else:
            first_day = switch_month(first_day, n_days, 7)

    return full_calendar


def getUserDetails(session):
    userDetails = []
    r = session.get(prefix + '/area_tutore')
    soup = BeautifulSoup(r.text, features='lxml')
    rawName = soup.find('div', class_='first last dropdown').text.strip()
    userName = lowerCase(rawName.split('-')[0])
    userClass = rawName.split('-')[1].strip()
    userDetails.append(userName)
    userDetails.append(userClass)
    return userDetails
    



#session = login('apzla56677', 'MichiRegistro2021.')
#session = login('andj81z54', 'Parhamnafas10!')
#print(calendar(session))



'''
#PER ANDARE ALL'ANNO SCOLASTICO PRECEDENTE
    r = session.get(prefix)
    soup = BeautifulSoup(r.text, features='lxml')
    for dropdownLink in soup.findAll('a', class_='dropdown-item'):
        schoolYear = dropdownLink.get('href')
        session.get(prefix + schoolYear)
        break

'''