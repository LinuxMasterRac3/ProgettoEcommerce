# Usa un'immagine Node.js ufficiale. Consigliabile usare una versione LTS.
FROM node:20-alpine

# Imposta la directory di lavoro nell'immagine
WORKDIR /app

# Copia package.json e package-lock.json (o yarn.lock)
COPY package.json package-lock.json* ./

# Installa le dipendenze del progetto
# Usare npm ci invece di npm install per build più veloci e affidabili
RUN npm ci

# Copia il resto del codice dell'applicazione
COPY # Copia il resto del codice dell'applicazione
. .

# Esponi la porta su cui l'applicazione Vite gira (di default 5173)
EXPOSE 5173

# Comando per avviare l'applicazione in modalità sviluppo
CMD ["npm", "run", "dev", "--", "--host"]
# sudo docker run -p 5173:5173 start-site
# per avviarlo sudo docker run -p 5173:5173 start-site