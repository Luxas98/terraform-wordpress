def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('--env', default='dev')
    args, _ = parser.parse_known_args()

    if args.env == 'dev':
        os.environ['FLASK_DEBUG'] = 'true'

    cli.add_command(run_command)
    cli.main(args=sys.argv[1:])


if __name__ == '__main__':
    main()