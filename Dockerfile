FROM ubuntu
#
ADD ./bin/fruit-basket.sh /usr/bin/fruit-basket.sh
RUN chmod +x /usr/bin/fruit-basket.sh
#
ADD ./bin/run-fruit-basket.sh /usr/bin/run-fruit-basket.sh
RUN chmod +x /usr/bin/run-fruit-basket.sh
#
CMD ["/usr/bin/run-fruit-basket.sh"]
