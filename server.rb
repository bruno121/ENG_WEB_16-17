class Server
  require "socket"
    def initialize( port, ip )
      @server = TCPServer.open( ip, port )
      @connections = Hash.new
      @clients = Hash.new
      @connections[:server] = @server
      @connections[:clients] = @clients
      @leiturasruido=0
      @leiturastemp=0
       run
    end


    def run
      loop {
        Thread.start(@server.accept) do | client |
          nick_name = client.gets.chomp.to_sym

          puts "Novo cliente: #{nick_name}"
          @connections[:clients][nick_name] = client
          client.puts "Connection established"
          listen_user_messages(client)
          end
    }.join
    end

    def listen_user_messages(client)
      loop{
        msg = client.gets.chomp
        if msg.split(",")[0]=="M"
          id=msg.split(",")[1].to_i
          valor=msg.split(",")[2].to_i
          timeStamp=msg.split(",")[3]
          tipo=msg.split(",")[4]

          require 'sqlite3'
          begin
            db=SQLite3::Database.open 'BaseDeDadosXDK'
            db.execute "CREATE TABLE IF NOT EXISTS dados_novos1  (id INTEGER,valor INTEGER,time TIME,tipo TEXT);"
            db.execute "INSERT INTO dados_novos1 (id,valor,time,tipo) VALUES(?, ?, ?, ?);",id,valor,timeStamp,tipo
          end
          if(tipo=="ruido")
            @leiturasruido+=1
            end
            if(tipo=="temperatura")
            @leiturastemp+=1
          end
          end
            if (msg.split(",")[0]=="off" && msg.split(",")[1]=="ruido")

              @connections[:clients].each do |client|


                string=(client.first).to_s

                if(string=="ruido")

                  @clients.delete(client.first)
                  client.last.puts("A CONEXÃO FECHOU!")
                  client.last.puts("numero de leituras de ruido:#{@leiturasruido}")
                  client.last.close
                  @leiturasruido=0
                  puts("Sensor de Ruido Desligado!")

                end
              end
            end

        if (msg.split(",")[0]=="off" && msg.split(",")[1]=="temperatura")

          @connections[:clients].each do |client|

          string=(client.first).to_s

          if(string=="temperatura")

                    @clients.delete(client.first)
                    client.last.puts("A CONEXÃO FECHOU!")
                    client.last.puts("numero de leituras de temperatura:#{@leiturastemp}")
                  client.last.close
                    @leiturastemp=0
                    puts("Sensor de Temperatura Desligado!")
                 end

              end
        end

            if(msg.split(",")[0]=="Lista")
              @connections[:clients].each do |name|
                  client.puts "#{name}"

            end
            end

            if(msg.split(",")[0]=="10")
             if(msg.split(",")[1]=="ruido")
             require 'sqlite3'
              begin
                db=SQLite3::Database.open 'BaseDeDadosXDK'
                result=db.execute "SELECT * FROM dados_novos1 WHERE id=2 ORDER BY time DESC LIMIT 10; "

                  client.puts result

                end
                end

             if (msg.split(",")[1]=="temperatura")
              require 'sqlite3'
              begin
                db=SQLite3::Database.open 'BaseDeDadosXDK'
                result=db.execute "SELECT * FROM dados_novos1 WHERE id=1 ORDER BY time DESC LIMIT 10;"
                  client.puts result
              end
             end
             end
          if(msg.split(",")[0]=="num" && msg.split(",")[1]=="temperatura" )
                client.puts("numero de leituras de temperatura:#{@leiturastemp}")

          end

          if(msg.split(",")[0]=="num" && msg.split(",")[1]=="ruido" )
          client.puts("numero de leituras de ruido:#{@leiturasruido}")

        end

            if (msg=="op")
              client.puts("OPÇÕES")
              client.puts("10,ruido-----> saber leituras de ruido")
              client.puts("10,temperatura-----> saber leitura de temperatura")
              client.puts("off,ruido/temperatura -----> desligar xdk do ruido ou temperatura")
             client.puts("Lista -----> Lista de xdk/utilizadores ligados")
             client.puts("num,ruid/temperatura -----> numero de leituras de ruido ou temperatura")
            end
      }
    end

  Server.new( 3000, "127.0.0.1")
  end
