const fs = require("fs").promises;
const path = require("path");
const Database = require("./Database");

class Status {
	/**
	 * Lê o arquivo de status dos serviços
	 * @returns {Promise<Object>} Objeto com o status dos serviços
	 */
	static async getServicesStatus() {
		// Chamado a cada mensagem recebida; o arquivo so muda a cada 30s (BotAPI.checkServices)
		if (Status._cache && Date.now() - Status._cacheAt < 10000) return Status._cache;
		try {
			const database = Database.getInstance();
			const servicesPath = path.join(database.databasePath, "services-status.json");
			const data = await fs.readFile(servicesPath, "utf8");
			Status._cache = JSON.parse(data);
			Status._cacheAt = Date.now();
			return Status._cache;
		} catch (error) {
			// Retorna status default (tudo down) em caso de erro
			return {
				whatsgoapi: "unknown",
				imagine: "down",
				llm: "down",
				whisper: "down",
				f5tts: "down"
			};
		}
	}
}

Status._cache = null;
Status._cacheAt = 0;

module.exports = Status;
